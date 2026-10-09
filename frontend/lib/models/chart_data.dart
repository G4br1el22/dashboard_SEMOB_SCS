import 'kpi_model.dart';

class FaixaHoraria {
  final String rotulo; // "04h"
  final double pagantes;
  final double naoPagantes;
  final double viagens;

  const FaixaHoraria({
    required this.rotulo,
    required this.pagantes,
    required this.naoPagantes,
    required this.viagens,
  });

  double get total => pagantes + naoPagantes;

  factory FaixaHoraria.fromJson(Map<String, dynamic> j) => FaixaHoraria(
        rotulo: j['faixa'],
        pagantes: (j['pagantes'] as num).toDouble(),
        naoPagantes: (j['nao_pagantes'] as num).toDouble(),
        viagens: (j['viagens'] as num).toDouble(),
      );
}

class PassageirosData {
  final DateTime dataReferencia;
  final KpiModel pagantes;
  final KpiModel naoPagantes;
  final List<FaixaHoraria> faixas;

  const PassageirosData({
    required this.dataReferencia,
    required this.pagantes,
    required this.naoPagantes,
    required this.faixas,
  });

  num get total => pagantes.valor + naoPagantes.valor;
  double get pctNaoPagantes => total == 0 ? 0 : naoPagantes.valor / total * 100;
}
