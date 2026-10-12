enum KpiFormato { inteiro, km, moeda }

class KpiModel {
  final String titulo;
  final num valor;

  /// null = sem comparação selecionada (o card esconde o selo)
  final double? variacaoPercentual;
  final List<double> sparkline;
  final KpiFormato formato;

  /// false para indicadores onde subir é ruim (ex.: custo operacional).
  /// Define a cor do selo e da mini-linha: verde = bom, vermelho = ruim.
  final bool altaEhBoa;

  const KpiModel({
    required this.titulo,
    required this.valor,
    required this.variacaoPercentual,
    required this.sparkline,
    this.formato = KpiFormato.inteiro,
    this.altaEhBoa = true,
  });

  /// JSON esperado: {"valor": 42380, "variacao": 3.1, "sparkline": [..]}
  factory KpiModel.fromJson(
    Map<String, dynamic> j, {
    required String titulo,
    KpiFormato formato = KpiFormato.inteiro,
    bool altaEhBoa = true,
  }) =>
      KpiModel(
        titulo: titulo,
        valor: j['valor'] as num,
        variacaoPercentual: (j['variacao'] as num?)?.toDouble(),
        sparkline: ((j['sparkline'] ?? []) as List).map((e) => (e as num).toDouble()).toList(),
        formato: formato,
        altaEhBoa: altaEhBoa,
      );
}
