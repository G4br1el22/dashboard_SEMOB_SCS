import 'dart:math';

import '../models/chart_data.dart';
import '../models/filtros.dart';
import '../models/kpi_model.dart';
import 'passageiros_repository.dart';

/// Dados fictícios que reagem aos filtros, só para desenvolver a UI.
class MockPassageirosRepository implements PassageirosRepository {
  /// "Ontem" fictício (data do mockup).
  static final DateTime _ref = DateTime(2026, 2, 17);

  @override
  Future<PassageirosData> carregar(FiltrosDashboard f) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final (inicio, fim) = _intervalo(f);
    return inicio == fim ? _porHora(f, inicio) : _porDia(f, inicio, fim);
  }

  (DateTime, DateTime) _intervalo(FiltrosDashboard f) {
    DateTime d(DateTime x) => DateTime(x.year, x.month, x.day);
    switch (f.periodo) {
      case Periodo.dia:
        return (_ref, _ref);
      case Periodo.semana:
        return (_ref.subtract(const Duration(days: 6)), _ref);
      case Periodo.quinzena:
        return (_ref.subtract(const Duration(days: 14)), _ref);
      case Periodo.mes:
        return (_ref.subtract(const Duration(days: 29)), _ref);
      case Periodo.datas:
        final r = f.intervalo;
        if (r == null) return (_ref, _ref);
        return (d(r.start), d(r.end));
    }
  }

  // Variação fictícia conforme comparação escolhida
  double? _variacao(FiltrosDashboard f, bool pagantes) {
    final i = f.periodo.index;
    final base = pagantes ? [3.1, 2.4, 1.9, 4.2, 2.8][i] : [5.8, 4.1, 3.5, 6.3, 5.0][i];
    return switch (f.comparacao) {
      Comparacao.anoAnterior => base,
      Comparacao.periodoAnterior => -base * 0.6,
      Comparacao.nenhuma => null,
    };
  }

  PassageirosData _porHora(FiltrosDashboard f, DateTime dia) {
    const rotulos = ['04h', '06h', '08h', '10h', '12h', '14h', '16h', '18h', '20h', '22h'];
    const pag = [1280, 5300, 8000, 4400, 5100, 4000, 4800, 6900, 2100, 500];
    const nao = [250, 1500, 3660, 1700, 2000, 1500, 1800, 2400, 800, 300];
    const via = [60, 140, 190, 120, 130, 110, 125, 160, 80, 40];
    final fator = f.apenasDiasUteis ? 1.0 : 0.85;

    final serie = [
      for (var i = 0; i < rotulos.length; i++)
        PontoDemanda(
          rotulo: rotulos[i],
          pagantes: (pag[i] * fator).roundToDouble(),
          naoPagantes: (nao[i] * fator).roundToDouble(),
          viagens: (via[i] * fator).roundToDouble(),
        ),
    ];
    return _montar(f, dia, dia, Granularidade.hora, serie,
        sparkPag: const [3, 5, 4, 6, 4.5, 7, 7.6, 8],
        sparkNao: const [3, 4.5, 5, 4.6, 5.8, 6.2, 7.2, 8]);
  }

  PassageirosData _porDia(FiltrosDashboard f, DateTime inicio, DateTime fim) {
    final serie = <PontoDemanda>[];
    var d = inicio;
    var guarda = 0;
    while (!d.isAfter(fim) && guarda++ < 120) {
      final fimDeSemana = d.weekday >= 6;
      if (!(f.apenasDiasUteis && fimDeSemana)) {
        final fatorSemana = d.weekday == 6 ? 0.55 : (d.weekday == 7 ? 0.35 : 1.0);
        final ruido = 0.92 + 0.16 * (sin(d.difference(DateTime(2026)).inDays * 1.7) + 1) / 2;
        final pag = (42000 * fatorSemana * ruido).roundToDouble();
        serie.add(PontoDemanda(
          rotulo: '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}',
          pagantes: pag,
          naoPagantes: (pag * 0.375 * (1.05 - ruido * 0.05)).roundToDouble(),
          viagens: (pag / 260).roundToDouble(),
        ));
      }
      d = DateTime(d.year, d.month, d.day + 1);
    }
    return _montar(f, inicio, fim, Granularidade.dia, serie,
        sparkPag: serie.map((p) => p.pagantes).toList(),
        sparkNao: serie.map((p) => p.naoPagantes).toList());
  }

  PassageirosData _montar(
    FiltrosDashboard f,
    DateTime inicio,
    DateTime fim,
    Granularidade g,
    List<PontoDemanda> serie, {
    required List<double> sparkPag,
    required List<double> sparkNao,
  }) {
    final totPag = serie.fold<double>(0, (a, p) => a + p.pagantes);
    final totNao = serie.fold<double>(0, (a, p) => a + p.naoPagantes);
    return PassageirosData(
      dataInicio: inicio,
      dataFim: fim,
      granularidade: g,
      pagantes: KpiModel(
        titulo: 'Passageiros pagantes',
        valor: totPag,
        variacaoPercentual: _variacao(f, true),
        sparkline: sparkPag,
      ),
      naoPagantes: KpiModel(
        titulo: 'Passageiros não pagantes',
        valor: totNao,
        variacaoPercentual: _variacao(f, false),
        sparkline: sparkNao,
      ),
      serie: serie,
    );
  }
}
