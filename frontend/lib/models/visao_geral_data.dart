import 'chart_data.dart';
import 'kpi_model.dart';

/// Um ponto do gráfico "Desempenho financeiro" (mesmo eixo X da demanda).
class PontoFinanceiro {
  final String rotulo;
  final double receita;
  final double custo;

  const PontoFinanceiro({required this.rotulo, required this.receita, required this.custo});

  factory PontoFinanceiro.fromJson(Map<String, dynamic> j) => PontoFinanceiro(
        rotulo: j['rotulo'] as String,
        receita: (j['receita'] as num).toDouble(),
        custo: (j['custo'] as num).toDouble(),
      );
}

enum StatusLinha { normal, atencao, critico }

/// Uma linha da tabela "Desempenho por linha".
class LinhaDesempenho {
  final String codigo; // "201"
  final String nome; // "Terminal SCS ↔ Centro"
  final num km;
  final num viagens;
  final num pagantes;
  final num naoPagantes;
  final double ocupacao; // %
  final double pontualidade; // %
  final StatusLinha status;

  const LinhaDesempenho({
    required this.codigo,
    required this.nome,
    required this.km,
    required this.viagens,
    required this.pagantes,
    required this.naoPagantes,
    required this.ocupacao,
    required this.pontualidade,
    required this.status,
  });

  factory LinhaDesempenho.fromJson(Map<String, dynamic> j) => LinhaDesempenho(
        codigo: j['codigo'].toString(),
        nome: j['nome'] as String,
        km: j['km'] as num,
        viagens: j['viagens'] as num,
        pagantes: j['pagantes'] as num,
        naoPagantes: j['nao_pagantes'] as num,
        ocupacao: (j['ocupacao'] as num).toDouble(),
        pontualidade: (j['pontualidade'] as num).toDouble(),
        status: switch (j['status']) {
          'atencao' => StatusLinha.atencao,
          'critico' => StatusLinha.critico,
          _ => StatusLinha.normal,
        },
      );
}

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
  final List<PontoFinanceiro> financeiro;
  final List<LinhaDesempenho> linhas;

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
    required this.financeiro,
    required this.linhas,
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
        financeiro: (j['financeiro'] as List).map((e) => PontoFinanceiro.fromJson(e)).toList(),
        linhas: (j['linhas'] as List).map((e) => LinhaDesempenho.fromJson(e)).toList(),
      );
}
