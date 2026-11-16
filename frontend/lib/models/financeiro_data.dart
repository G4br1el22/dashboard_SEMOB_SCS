import 'json_values.dart';
import 'chart_data.dart';
import 'kpi_model.dart';
import 'visao_geral_data.dart' show PontoFinanceiro;

class FinanceiroData {
  final DatasetInfo info;
  final DateTime dataInicio;
  final DateTime dataFim;
  final Granularidade granularidade;
  final KpiModel receita;
  final KpiModel custo;
  final KpiModel? vendasCreditos;

  /// Total de passageiros pagantes no período (base dos indicadores "por passageiro").
  final num? pagantes;
  final List<PontoFinanceiro> financeiro;

  const FinanceiroData({
    this.info = const DatasetInfo(),
    required this.dataInicio,
    required this.dataFim,
    required this.granularidade,
    required this.receita,
    required this.custo,
    this.vendasCreditos,
    required this.pagantes,
    required this.financeiro,
  });

  num? get resultado => receita.valor == null || custo.valor == null
      ? null
      : receita.valor! - custo.valor!;
  double? get cobertura =>
      receita.valor == null || custo.valor == null || custo.valor == 0
          ? null
          : receita.valor! / custo.valor! * 100;
  double? get custoPorPassageiro =>
      pagantes == null || pagantes == 0 || custo.valor == null
          ? null
          : custo.valor! / pagantes!;
  double? get receitaPorPassageiro =>
      pagantes == null || pagantes == 0 || receita.valor == null
          ? null
          : receita.valor! / pagantes!;

  /// Veja o contrato completo em API_CONTRATO.md
  factory FinanceiroData.fromJson(Map<String, dynamic> j) => FinanceiroData(
        info: DatasetInfo.fromJson(j),
        vendasCreditos: j['vendas_creditos'] == null
            ? null
            : KpiModel.fromJson(j['vendas_creditos'],
                titulo: 'Vendas de créditos', formato: KpiFormato.moeda),
        dataInicio: DateTime.parse(j['data_inicio'] as String),
        dataFim: DateTime.parse(j['data_fim'] as String),
        granularidade: j['granularidade'] == 'hora'
            ? Granularidade.hora
            : Granularidade.dia,
        receita: KpiModel.fromJson(j['receita'],
            titulo: 'Receita tarifária', formato: KpiFormato.moeda),
        custo: KpiModel.fromJson(j['custo'],
            titulo: 'Custo operacional',
            formato: KpiFormato.moeda,
            altaEhBoa: false),
        pagantes: numeroJson(j['pagantes']['valor']),
        financeiro: (j['financeiro'] as List)
            .map((e) => PontoFinanceiro.fromJson(e))
            .toList(),
      );
}
