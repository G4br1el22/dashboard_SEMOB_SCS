import 'chart_data.dart';
import 'kpi_model.dart';
import 'visao_geral_data.dart' show PontoFinanceiro;

class FinanceiroData {
  final DateTime dataInicio;
  final DateTime dataFim;
  final Granularidade granularidade;
  final KpiModel receita;
  final KpiModel custo;

  /// Total de passageiros pagantes no período (base dos indicadores "por passageiro").
  final num pagantes;
  final List<PontoFinanceiro> financeiro;

  const FinanceiroData({
    required this.dataInicio,
    required this.dataFim,
    required this.granularidade,
    required this.receita,
    required this.custo,
    required this.pagantes,
    required this.financeiro,
  });

  // Indicadores derivados (calculados no front a partir dos totais).
  num get resultado => receita.valor - custo.valor;
  double get cobertura => custo.valor == 0 ? 0 : receita.valor / custo.valor * 100;
  double get custoPorPassageiro => pagantes == 0 ? 0 : custo.valor / pagantes;
  double get receitaPorPassageiro => pagantes == 0 ? 0 : receita.valor / pagantes;

  /// Veja o contrato completo em API_CONTRATO.md
  factory FinanceiroData.fromJson(Map<String, dynamic> j) => FinanceiroData(
        dataInicio: DateTime.parse(j['data_inicio'] as String),
        dataFim: DateTime.parse(j['data_fim'] as String),
        granularidade: j['granularidade'] == 'hora' ? Granularidade.hora : Granularidade.dia,
        receita:
            KpiModel.fromJson(j['receita'], titulo: 'Receita tarifária', formato: KpiFormato.moeda),
        custo: KpiModel.fromJson(j['custo'],
            titulo: 'Custo operacional', formato: KpiFormato.moeda, altaEhBoa: false),
        pagantes: j['pagantes'] as num,
        financeiro: (j['financeiro'] as List).map((e) => PontoFinanceiro.fromJson(e)).toList(),
      );
}
