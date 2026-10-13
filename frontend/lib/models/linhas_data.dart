import 'visao_geral_data.dart' show LinhaDesempenho, StatusLinha;

class LinhasData {
  /// Quando o back sincronizou os dados com o Smart Data.
  final DateTime sincronizadoEm;
  final List<LinhaDesempenho> linhas;

  const LinhasData({required this.sincronizadoEm, required this.linhas});

  int get total => linhas.length;
  int _conta(StatusLinha s) => linhas.where((l) => l.status == s).length;
  int get normais => _conta(StatusLinha.normal);
  int get atencao => _conta(StatusLinha.atencao);
  int get criticas => _conta(StatusLinha.critico);

  double pct(int n) => total == 0 ? 0 : n / total * 100;

  /// Veja o contrato completo em API_CONTRATO.md
  factory LinhasData.fromJson(Map<String, dynamic> j) => LinhasData(
        sincronizadoEm: DateTime.parse(j['sincronizado_em'] as String).toLocal(),
        linhas: (j['linhas'] as List).map((e) => LinhaDesempenho.fromJson(e)).toList(),
      );
}
