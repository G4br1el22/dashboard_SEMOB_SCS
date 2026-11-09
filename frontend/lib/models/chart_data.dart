import 'json_values.dart';
import 'kpi_model.dart';

enum Granularidade { hora, dia }

/// Um ponto do gráfico de barras (uma faixa horária ou um dia).
class PontoDemanda {
  final String rotulo; // "08h" ou "17/02"
  final double? pagantes;
  final double? naoPagantes;
  final double? viagens;

  const PontoDemanda({
    required this.rotulo,
    required this.pagantes,
    required this.naoPagantes,
    required this.viagens,
  });

  double? get total =>
      pagantes == null || naoPagantes == null ? null : pagantes! + naoPagantes!;

  factory PontoDemanda.fromJson(Map<String, dynamic> j) => PontoDemanda(
        rotulo: j['rotulo'] as String,
        pagantes: numeroJson(j['pagantes'])?.toDouble(),
        naoPagantes: numeroJson(j['nao_pagantes'])?.toDouble(),
        viagens: numeroJson(j['viagens'])?.toDouble(),
      );
}

class PassageirosData {
  final DatasetInfo info;
  final DateTime dataInicio;
  final DateTime dataFim;
  final Granularidade granularidade;
  final KpiModel pagantes;
  final KpiModel naoPagantes;
  final List<PontoDemanda> serie;

  const PassageirosData({
    this.info = const DatasetInfo(),
    required this.dataInicio,
    required this.dataFim,
    required this.granularidade,
    required this.pagantes,
    required this.naoPagantes,
    required this.serie,
  });

  num? get total => pagantes.valor == null || naoPagantes.valor == null
      ? null
      : pagantes.valor! + naoPagantes.valor!;

  /// Veja o contrato completo em API_CONTRATO.md
  factory PassageirosData.fromJson(Map<String, dynamic> j) => PassageirosData(
        info: DatasetInfo.fromJson(j),
        dataInicio: DateTime.parse(j['data_inicio'] as String),
        dataFim: DateTime.parse(j['data_fim'] as String),
        granularidade: j['granularidade'] == 'hora'
            ? Granularidade.hora
            : Granularidade.dia,
        pagantes:
            KpiModel.fromJson(j['pagantes'], titulo: 'Passageiros pagantes'),
        naoPagantes: KpiModel.fromJson(j['nao_pagantes'],
            titulo: 'Passageiros não pagantes'),
        serie:
            (j['serie'] as List).map((e) => PontoDemanda.fromJson(e)).toList(),
      );
}
