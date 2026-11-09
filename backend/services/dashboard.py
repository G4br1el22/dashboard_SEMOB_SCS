"""Regras compartilhadas por telas e relatórios. Aritmética com Decimal."""
from collections import defaultdict
from datetime import date, datetime, timedelta, timezone
from decimal import Decimal

from backend.models.schemas import Comparison, Period
from backend.repositories.data import decimal_value

METRICS = {
    "quilometragem": (["operacao_diaria", "operacao_linha_diaria"], ["kmTotal"]),
    "viagens": (["operacao_diaria", "operacao_linha_diaria"], ["nrViagensRealiz"]),
    "pagantes": (["passageiros_diarios"], ["Catraca", "Antecipados"]),
    "nao_pagantes": (["passageiros_diarios"], ["Não Pagantes"]),
    "vendas_creditos": (["vendas_utilizacao"], ["Total Vendas"]),
}


def bounds(filters, latest):
    if filters.periodo == Period.datas:
        return filters.data_inicio, filters.data_fim
    length = {Period.dia: 1, Period.semana: 7, Period.quinzena: 15, Period.mes: 30}[filters.periodo]
    return latest - timedelta(days=length - 1), latest


def previous_bounds(filters, start, end):
    if filters.comparacao == Comparison.nenhuma:
        return None
    if filters.comparacao == Comparison.periodo_anterior:
        delta = timedelta(days=(end - start).days + 1)
        return start - delta, end - delta
    def last_year(day):
        try:
            return day.replace(year=day.year - 1)
        except ValueError:
            return day.replace(year=day.year - 1, day=28)
    return last_year(start), last_year(end)


def days_in(start, end, weekdays):
    day = start
    while day <= end:
        if not weekdays or day.weekday() < 5:
            yield day.isoformat()
        day += timedelta(days=1)


def selected_rows(rows, line):
    if line is None:
        return rows
    # Não distribuir totais municipais entre linhas sem evidência.
    return [row for row in rows if str(row.get("valores", {}).get("Linha", "")) == line]


def daily_values(rows, days):
    groups = defaultdict(lambda: defaultdict(list))
    for row in rows:
        if row["data"] in days:
            groups[row["data"]][row["tipo"]].append(row.get("valores", {}))
    result = {}
    for day in days:
        values = {}
        for metric, (families, fields) in METRICS.items():
            family = next((family for family in families if groups[day][family]), None)
            source = groups[day][family] if family else []
            if metric == "viagens" and family == "operacao_linha_diaria":
                fields = ["nrViagens"]
            numbers = [decimal_value(row.get(field)) for row in source for field in fields]
            values[metric] = sum(numbers, Decimal(0)) if numbers and all(n is not None for n in numbers) else None
        values["receita"] = None  # Vendas de crédito não comprovam receita tarifária reconhecida.
        values["custo"] = None
        result[day] = values
    return result


def kpi(metric, daily, previous):
    values = [v[metric] for v in daily.values() if v[metric] is not None]
    old = [v[metric] for v in previous.values() if v[metric] is not None]
    value = sum(values, Decimal(0)) if values else None
    old_value = sum(old, Decimal(0)) if old else None
    complete = bool(daily) and len(values) == len(daily)
    comparable = complete and bool(previous) and len(old) == len(previous) and old_value not in (None, 0)
    return {"valor": value, "variacao": (value - old_value) / abs(old_value) * 100 if comparable else None,
            "sparkline": values if complete else [], "parcial": bool(values) and not complete,
            "dias_observados": len(values), "dias_esperados": len(daily)}


def line_summary(rows):
    groups = defaultdict(list)
    for row in rows:
        line = row.get("valores", {}).get("Linha")
        if line is not None and str(line).strip() and str(line).lower() not in {"total", "totais"}:
            groups[str(line)].append(row)
    result = []
    for code, group in sorted(groups.items()):
        daily = daily_values(group, sorted({row["data"] for row in group}))
        result.append({"codigo": code, "nome": "Linha " + code,
                       "km": kpi("quilometragem", daily, {})["valor"],
                       "viagens": kpi("viagens", daily, {})["valor"],
                       "pagantes": kpi("pagantes", daily, {})["valor"],
                       "nao_pagantes": kpi("nao_pagantes", daily, {})["valor"],
                       "ocupacao": None, "pontualidade": None, "status": "indisponivel"})
    return result


def build_dashboard(repository, filters):
    latest = repository.latest()
    start, end = bounds(filters, latest)
    days = list(days_in(start, end, filters.dias_uteis))
    rows = selected_rows(repository.read(start, end, filters.linha), filters.linha)
    rows = [row for row in rows if row["data"] in days]
    daily = daily_values(rows, days)
    past = previous_bounds(filters, start, end)
    previous = {}
    if past:
        old_days = list(days_in(*past, filters.dias_uteis))
        previous = daily_values(selected_rows(repository.read(*past, filters.linha), filters.linha), old_days)
    metrics = {metric: kpi(metric, daily, previous) for metric in [*METRICS, "receita", "custo"]}
    active = [decimal_value(row.get("valores", {}).get("nrVeiculos")) for row in rows
              if row["tipo"] == "operacao_diaria"]
    active = [value for value in active if value is not None]
    notices = ["Receita tarifária e custo operacional não têm fonte validada. Vendas de créditos são apresentadas separadamente.",
               "Ocupação, pontualidade, frota cadastrada, manutenção e idade não possuem fonte validada."]
    if filters.dias_uteis:
        notices.append("Filtro de segunda a sexta; feriados não são excluídos.")
    if any(metric["parcial"] for metric in metrics.values()):
        notices.append("Há lacunas: os totais parciais somam apenas dias observados. Comparações incompletas são omitidas.")
    if filters.linha:
        notices.append("Filtro de linha exclui totais municipais sem identificação de linha.")
    if repository.source == "demo":
        notices.insert(0, "DEMONSTRAÇÃO: dados inteiramente sintéticos; sem conexão ao Atlas.")
    return {"data_inicio": start.isoformat(), "data_fim": end.isoformat(), "granularidade": "dia",
            "fonte": repository.source, "ultima_data_disponivel": latest.isoformat(),
            "consultado_em": datetime.now(timezone.utc).isoformat(), "sincronizado_em": None,
            "sem_dados": not rows, "avisos": notices, **metrics,
            "serie": [{"rotulo": date.fromisoformat(day).strftime("%d/%m"), "data": day,
                       **{key: value[key] for key in ["pagantes", "nao_pagantes", "viagens"]}}
                      for day, value in daily.items()],
            "financeiro": [], "linhas": line_summary(rows),
            "frota": {"total": None, "em_operacao": max(active) if active else None,
                      "em_manutencao": None, "idade_media": None, "meta_idade": None},
            "diario": [{"data": day, **value} for day, value in daily.items()]}
