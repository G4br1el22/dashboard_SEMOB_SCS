import 'chart_data.dart';
import 'kpi_model.dart';

class VisaoGeralData {
  final DateTime dataInicio;
  final DateTime dataFim;
  final Granularidade granularidade;
  final KpiModel quilometragem;
  final KpiModel viagens;
  final KpiModel pagantes;
  final KpiModel naoPagantes;
  final KpiModel receita;
  final KpiModel custo;
  final List<PontoDemanda> serie;

  const VisaoGeralData({
    required this.dataInicio,
    required this.dataFim,
    required this.granularidade,
    required this.quilometragem,
    required this.viagens,
    required this.pagantes,
    required this.naoPagantes,
    required this.receita,
    required this.custo,
    required this.serie,
  });

  /// Ordem em que os 6 cartões aparecem na tela.
  List<KpiModel> get kpis => [quilometragem, viagens, pagantes, naoPagantes, receita, custo];

  /// Veja o contrato completo em API_CONTRATO.md
  factory VisaoGeralData.fromJson(Map<String, dynamic> j) => VisaoGeralData(
        dataInicio: DateTime.parse(j['data_inicio'] as String),
        dataFim: DateTime.parse(j['data_fim'] as String),
        granularidade: j['granularidade'] == 'hora' ? Granularidade.hora : Granularidade.dia,
        quilometragem:
            KpiModel.fromJson(j['quilometragem'], titulo: 'Quilometragem', formato: KpiFormato.km),
        viagens: KpiModel.fromJson(j['viagens'], titulo: 'Viagens realizadas'),
        pagantes: KpiModel.fromJson(j['pagantes'], titulo: 'Passageiros pagantes'),
        naoPagantes: KpiModel.fromJson(j['nao_pagantes'], titulo: 'Passageiros não pagantes'),
        receita:
            KpiModel.fromJson(j['receita'], titulo: 'Receita tarifária', formato: KpiFormato.moeda),
        custo: KpiModel.fromJson(j['custo'],
            titulo: 'Custo operacional', formato: KpiFormato.moeda, altaEhBoa: false),
        serie: (j['serie'] as List).map((e) => PontoDemanda.fromJson(e)).toList(),
      );
}
