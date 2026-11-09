import 'json_values.dart';
import 'visao_geral_data.dart' show LinhaDesempenho, StatusLinha;

class LinhasData {
  final DateTime dataInicio;
  final DateTime dataFim;
  final DatasetInfo info;

  /// Quando o back sincronizou os dados com o Smart Data.
  final DateTime? sincronizadoEm;
  final List<LinhaDesempenho> linhas;

  LinhasData(
      {this.sincronizadoEm,
      required this.linhas,
      DateTime? dataInicio,
      DateTime? dataFim,
      this.info = const DatasetInfo()})
      : dataInicio = dataInicio ?? DateTime(2026, 1, 1),
        dataFim = dataFim ?? DateTime(2026, 1, 1);

  int get total => linhas.length;
  int _conta(StatusLinha s) => linhas.where((l) => l.status == s).length;
  int get normais => _conta(StatusLinha.normal);
  int get atencao => _conta(StatusLinha.atencao);
  int get criticas => _conta(StatusLinha.critico);

  double pct(int n) => total == 0 ? 0 : n / total * 100;

  /// Veja o contrato completo em API_CONTRATO.md
  factory LinhasData.fromJson(Map<String, dynamic> j) => LinhasData(
        dataInicio: DateTime.parse(j['data_inicio']),
        dataFim: DateTime.parse(j['data_fim']),
        info: DatasetInfo.fromJson(j),
        sincronizadoEm: null,
        linhas: (j['linhas'] as List)
            .map((e) => LinhaDesempenho.fromJson(e))
            .toList(),
      );
}
