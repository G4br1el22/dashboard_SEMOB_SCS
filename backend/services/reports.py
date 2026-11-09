"""Exportações locais persistentes. Nenhuma escrita no MongoDB."""
from datetime import datetime, timezone
from decimal import Decimal
import json
from pathlib import Path
import re
from threading import Lock
from uuid import uuid4
from xml.sax.saxutils import escape

from openpyxl import Workbook
from openpyxl.styles import Alignment, Font, PatternFill
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle

TYPES = [
    {"id": "operacional_pdf", "titulo": "Resumo operacional", "formato": "pdf",
     "descricao": "Indicadores e série diária com período, origem e limitações.", "frequencia": "Sob demanda"},
    {"id": "operacional_xlsx", "titulo": "Dados operacionais em planilha", "formato": "xlsx",
     "descricao": "Resumo, dados diários e linhas para análise e conciliação.", "frequencia": "Sob demanda"},
]
LABELS = {"quilometragem": "Quilometragem (km)", "viagens": "Viagens realizadas",
          "pagantes": "Passageiros pagantes", "nao_pagantes": "Passageiros não pagantes",
          "vendas_creditos": "Vendas de créditos (R$)", "receita": "Receita tarifária (R$)",
          "custo": "Custo operacional (R$)"}


def text_value(value):
    if value is None:
        return "Indisponível"
    return f"{value:,.2f}".replace(",", "_").replace(".", ",").replace("_", ".")


def write_pdf(path, data, metadata):
    styles = getSampleStyleSheet()
    doc = SimpleDocTemplate(str(path), pagesize=A4, rightMargin=36, leftMargin=36,
                            topMargin=36, bottomMargin=36, title="SEMOB Resumo operacional")
    story = [Paragraph("SEMOB SCS", styles["Title"]), Paragraph("Resumo operacional", styles["Heading1"]),
             Paragraph(f"Período inclusivo: {data['data_inicio']} a {data['data_fim']}", styles["Normal"]),
             Paragraph("Origem: " + ("DEMONSTRAÇÃO SINTÉTICA" if data["fonte"] == "demo" else "MongoDB / dados_consulta"), styles["Normal"]),
             Paragraph("Gerado em UTC: " + metadata["gerado_em"], styles["Normal"]),
             Paragraph("Linha: " + escape(str(metadata["filtros"].get("linha") or "Todas")), styles["Normal"]),
             Paragraph("Segunda a sexta: " + ("sim" if metadata["filtros"]["dias_uteis"] else "não"), styles["Normal"]),
             Spacer(1, 12)]
    summary = [["Indicador", "Valor", "Cobertura de dias"]]
    for key, label in LABELS.items():
        metric = data[key]
        summary.append([label, text_value(metric["valor"]),
                        f"{metric['dias_observados']} / {metric['dias_esperados']}" + (" (parcial)" if metric["parcial"] else "")])
    story.append(styled_table(summary, [235, 140, 148]))
    story.append(Spacer(1, 12))
    for notice in data["avisos"]:
        story.extend([Paragraph(escape(notice), styles["Normal"]), Spacer(1, 5)])
    story.extend([Paragraph("Dados diários", styles["Heading2"]),
                  Paragraph("Traço indica dado ausente; lacunas não equivalem a zero.", styles["Normal"]), Spacer(1, 8)])
    columns = ["quilometragem", "viagens", "pagantes", "nao_pagantes", "vendas_creditos"]
    daily = [["Data", "Km", "Viagens", "Pagantes", "Não pag.", "Créditos R$"]]
    for row in data["diario"]:
        daily.append([row["data"], *[text_value(row[key]) if row[key] is not None else "-" for key in columns]])
    if len(daily) == 1:
        story.append(Paragraph("Sem dados para o filtro selecionado.", styles["Normal"]))
    else:
        story.append(styled_table(daily, [78, 85, 70, 85, 85, 120]))
    def footer(canvas, document):
        canvas.setFont("Helvetica", 8)
        canvas.drawString(36, 20, "SEMOB SCS | Consulta local | " + metadata["id"][:8])
        canvas.drawRightString(A4[0] - 36, 20, str(document.page))
    doc.build(story, onFirstPage=footer, onLaterPages=footer)


def styled_table(rows, widths):
    table = Table(rows, colWidths=widths, repeatRows=1, hAlign="LEFT")
    table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#14283f")),
        ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
        ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
        ("FONTSIZE", (0, 0), (-1, -1), 8),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 7),
        ("TOPPADDING", (0, 0), (-1, -1), 7),
        ("ALIGN", (1, 1), (-1, -1), "RIGHT"),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, colors.HexColor("#eef3f7")]),
        ("LINEBELOW", (0, 0), (-1, 0), 1, colors.HexColor("#1d8b82")),
    ]))
    return table


def write_xlsx(path, data, metadata):
    book = Workbook()
    sheet = book.active
    sheet.title = "Resumo"
    sheet.append(["SEMOB SCS", "DEMONSTRAÇÃO SINTÉTICA" if data["fonte"] == "demo" else "MongoDB / dados_consulta"])
    sheet.append(["Início", data["data_inicio"], "Fim", data["data_fim"]])
    sheet.append(["Gerado em UTC", metadata["gerado_em"]])
    sheet.append(["Segunda a sexta", metadata["filtros"]["dias_uteis"], "Linha", metadata["filtros"].get("linha") or "Todas"])
    sheet.append(["Indicador", "Valor", "Dias observados", "Dias esperados", "Parcial"])
    for key, label in LABELS.items():
        metric = data[key]
        sheet.append([label, metric["valor"], metric["dias_observados"], metric["dias_esperados"], metric["parcial"]])
    for notice in data["avisos"]:
        sheet.append([notice])
    daily = book.create_sheet("Diário")
    daily.append(["Data", *LABELS.values()])
    for row in data["diario"]:
        daily.append([row["data"], *[row[key] for key in LABELS]])
    lines = book.create_sheet("Linhas")
    lines.append(["Linha", "Nome", "Km", "Viagens", "Pagantes", "Não pagantes"])
    for row in data["linhas"]:
        lines.append([row[key] for key in ["codigo", "nome", "km", "viagens", "pagantes", "nao_pagantes"]])
    for tab in book:
        tab.freeze_panes = "B2"
        tab.auto_filter.ref = tab.dimensions
        for cell in tab[1]:
            cell.fill = PatternFill("solid", fgColor="14283F")
            cell.font = Font(color="FFFFFF", bold=True)
        for col in tab.columns:
            tab.column_dimensions[col[0].column_letter].width = min(48, max(18, max(len(str(c.value or "")) for c in col) + 2))
        for row in tab:
            for cell in row:
                if isinstance(cell.value, (int, float, Decimal)) and not isinstance(cell.value, bool):
                    cell.number_format = '#,##0.00'
                if isinstance(cell.value, str):
                    cell.data_type = "s"  # Identificadores não viram fórmulas.
                cell.alignment = Alignment(vertical="top")
    book.save(path)


class ReportStore:
    def __init__(self, directory, source):
        self.directory = Path(directory) / source
        self.lock = Lock()

    def list(self):
        if not self.directory.exists():
            return []
        result = []
        for path in self.directory.glob("*.json"):
            try:
                meta = json.loads(path.read_text(encoding="utf-8"))
                if self.file(meta["id"], meta["formato"]).is_file():
                    result.append(meta)
            except (ValueError, KeyError, OSError):
                continue
        return sorted(result, key=lambda item: item["gerado_em"], reverse=True)[:50]

    def file(self, report_id, extension):
        if not re.fullmatch(r"[0-9a-f]{32}", report_id) or extension not in {"pdf", "xlsx"}:
            raise FileNotFoundError
        return self.directory / f"{report_id}.{extension}"

    def get(self, report_id):
        self.file(report_id, "pdf")  # Validar ID antes de montar qualquer caminho.
        try:
            metadata = json.loads((self.directory / (report_id + ".json")).read_text(encoding="utf-8"))
            path = self.file(report_id, metadata["formato"])
            if not path.is_file():
                raise FileNotFoundError
            return metadata, path
        except (OSError, ValueError, KeyError):
            raise FileNotFoundError from None

    def generate(self, request, data):
        report_type = next(t for t in TYPES if t["id"] == request.tipo)
        metadata = {"id": uuid4().hex, "titulo": report_type["titulo"], "formato": report_type["formato"],
                    "gerado_em": datetime.now(timezone.utc).isoformat(), "fonte": data["fonte"],
                    "data_inicio": data["data_inicio"], "data_fim": data["data_fim"],
                    "filtros": request.model_dump(mode="json", exclude={"tipo"})}
        with self.lock:
            self.directory.mkdir(parents=True, exist_ok=True)
            path = self.file(metadata["id"], metadata["formato"])
            try:
                (write_pdf if metadata["formato"] == "pdf" else write_xlsx)(path, data, metadata)
                (self.directory / (metadata["id"] + ".json")).write_text(json.dumps(metadata, ensure_ascii=False), encoding="utf-8")
            except Exception:
                path.unlink(missing_ok=True)
                raise
        return metadata
