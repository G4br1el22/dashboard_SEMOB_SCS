/// Decimal exato via string na API; double apenas para desenho e formatação.
num? numeroJson(dynamic value) => value == null
    ? null
    : value is num
        ? value
        : num.parse(value as String);

class DatasetInfo {
  final bool semDados;
  final List<String> avisos;
  const DatasetInfo({this.semDados = false, this.avisos = const []});
  factory DatasetInfo.fromJson(Map<String, dynamic> json) => DatasetInfo(
        semDados: json['sem_dados'] == true,
        avisos: ((json['avisos'] ?? []) as List).cast<String>(),
      );
}
