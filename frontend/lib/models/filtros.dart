enum Periodo { dia, semana, quinzena, mes, datas }

extension PeriodoLabel on Periodo {
  String get label => switch (this) {
        Periodo.dia => 'Dia',
        Periodo.semana => 'Semana',
        Periodo.quinzena => 'Quinzena',
        Periodo.mes => 'Mês',
        Periodo.datas => 'Datas',
      };
}
