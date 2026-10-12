import 'package:flutter/material.dart' show DateTimeRange;
import 'package:intl/intl.dart';

enum Periodo { dia, semana, quinzena, mes, datas }

extension PeriodoX on Periodo {
  String get label => switch (this) {
        Periodo.dia => 'Dia',
        Periodo.semana => 'Semana',
        Periodo.quinzena => 'Quinzena',
        Periodo.mes => 'Mês',
        Periodo.datas => 'Datas',
      };

  /// Valor enviado ao back (?periodo=...)
  String get apiValue => name; // dia | semana | quinzena | mes | datas
}

enum Comparacao { anoAnterior, periodoAnterior, nenhuma }

extension ComparacaoX on Comparacao {
  String rotulo(int anoAtual) => switch (this) {
        Comparacao.anoAnterior => 'Mesmo período de ${anoAtual - 1}',
        Comparacao.periodoAnterior => 'Período anterior',
        Comparacao.nenhuma => 'Sem comparação',
      };

  /// Valor enviado ao back (?comparacao=...)
  String get apiValue => switch (this) {
        Comparacao.anoAnterior => 'ano_anterior',
        Comparacao.periodoAnterior => 'periodo_anterior',
        Comparacao.nenhuma => 'nenhuma',
      };
}

/// Todos os filtros da tela em um objeto só (imutável).
class FiltrosDashboard {
  final Periodo periodo;
  final Comparacao comparacao;
  final bool apenasDiasUteis;

  /// Só usado quando periodo == Periodo.datas
  final DateTimeRange? intervalo;

  const FiltrosDashboard({
    this.periodo = Periodo.dia,
    this.comparacao = Comparacao.anoAnterior,
    this.apenasDiasUteis = true,
    this.intervalo,
  });

  FiltrosDashboard copyWith({
    Periodo? periodo,
    Comparacao? comparacao,
    bool? apenasDiasUteis,
    DateTimeRange? intervalo,
  }) =>
      FiltrosDashboard(
        periodo: periodo ?? this.periodo,
        comparacao: comparacao ?? this.comparacao,
        apenasDiasUteis: apenasDiasUteis ?? this.apenasDiasUteis,
        intervalo: intervalo ?? this.intervalo,
      );

  /// Query string da requisição ao back.
  Map<String, dynamic> toQuery() {
    final f = DateFormat('yyyy-MM-dd');
    return {
      'periodo': periodo.apiValue,
      'comparacao': comparacao.apiValue,
      'dias_uteis': apenasDiasUteis,
      if (periodo == Periodo.datas && intervalo != null) ...{
        'data_inicio': f.format(intervalo!.start),
        'data_fim': f.format(intervalo!.end),
      },
    };
  }
}
