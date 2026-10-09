class KpiModel {
  final String titulo;
  final num valor;
  final double variacaoPercentual;
  final List<double> sparkline;

  const KpiModel({
    required this.titulo,
    required this.valor,
    required this.variacaoPercentual,
    required this.sparkline,
  });

  factory KpiModel.fromJson(Map<String, dynamic> j) => KpiModel(
        titulo: j['titulo'],
        valor: j['valor'],
        variacaoPercentual: (j['variacao'] as num).toDouble(),
        sparkline: (j['sparkline'] as List).map((e) => (e as num).toDouble()).toList(),
      );
}
