class ReceitaDiaria {
  static const double tarifa = 5.0;

  final DateTime data;
  final int passageirosDinheiro;
  final int passageirosPrePago;
  final double valorVendasCredito;
  final double valorUsoCredito;

  const ReceitaDiaria({
    required this.data,
    required this.passageirosDinheiro,
    required this.passageirosPrePago,
    required this.valorVendasCredito,
    required this.valorUsoCredito,
  });

  double get receitaDinheiro => passageirosDinheiro * tarifa;

  double get receitaPrePaga => valorVendasCredito + valorUsoCredito;

  double get receitaTotal => receitaDinheiro + receitaPrePaga;

  factory ReceitaDiaria.fromCsvRow(List<dynamic> row) {
    return ReceitaDiaria(
      data: DateTime.parse(row[0].toString()),
      passageirosDinheiro: int.tryParse(row[1].toString()) ?? 0,
      passageirosPrePago: int.tryParse(row[2].toString()) ?? 0,
      valorVendasCredito: double.tryParse(row[4].toString()) ?? 0,
      valorUsoCredito: double.tryParse(row[5].toString()) ?? 0,
    );
  }
}