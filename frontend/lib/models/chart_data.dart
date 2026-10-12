import 'kpi_model.dart';

enum Granularidade { hora, dia }

/// Um ponto do gráfico de barras (uma faixa horária ou um dia).
class PontoDemanda {
  final String rotulo; // "08h" ou "17/02"
  final double pagantes;
  final double naoPagantes;
  final double viagens;

  const PontoDemanda({
    required this.rotulo,
    required this.pagantes,
    required this.naoPagantes,
    required this.viagens,
  });

  double get total => pagantes + naoPagantes;

  factory PontoDemanda.fromJson(Map<String, dynamic> j) => PontoDemanda(
        rotulo: j['rotulo'] as String,
        pagantes: (j['pagantes'] as num).toDouble(),
        naoPagantes: (j['nao_pagantes'] as num).toDouble(),
        viagens: (j['viagens'] as num).toDouble(),
      );
}

class PassageirosData {
  final DateTime dataInicio;
  final DateTime dataFim;
  final Granularidade granularidade;
  final KpiModel pagantes;
  final KpiModel naoPagantes;
  final List<PontoDemanda> serie;

  const PassageirosData({
    required this.dataInicio,
    required this.dataFim,
    required this.granularidade,
    required this.pagantes,
    required this.naoPagantes,
    required this.serie,
  });

  num get total => pagantes.valor + naoPagantes.valor;

  /// Veja o contrato completo em API_CONTRATO.md
  factory PassageirosData.fromJson(Map<String, dynamic> j) => PassageirosData(
        dataInicio: DateTime.parse(j['data_inicio'] as String),
        dataFim: DateTime.parse(j['data_fim'] as String),
        granularidade: j['granularidade'] == 'hora' ? Granularidade.hora : Granularidade.dia,
        pagantes: KpiModel.fromJson(j['pagantes'], titulo: 'Passageiros pagantes'),
        naoPagantes: KpiModel.fromJson(j['nao_pagantes'], titulo: 'Passageiros não pagantes'),
        serie: (j['serie'] as List).map((e) => PontoDemanda.fromJson(e)).toList(),
      );
}
