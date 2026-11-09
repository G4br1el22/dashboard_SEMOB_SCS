enum FormatoRelatorio { pdf, xlsx }

extension FormatoRelatorioX on FormatoRelatorio {
  String get rotulo => this == FormatoRelatorio.pdf ? 'PDF' : 'XLSX';

  static FormatoRelatorio doJson(String? v) => (v ?? '').toLowerCase() == 'xlsx'
      ? FormatoRelatorio.xlsx
      : FormatoRelatorio.pdf;
}

/// Um tipo de relatório que o usuário pode gerar (os 4 cartões).
class RelatorioTipo {
  final String id; // "operacional_diario"
  final String titulo;
  final String descricao;
  final FormatoRelatorio formato;
  final String frequencia; // "Diário", "Semanal", "Mensal", "Sob demanda"

  const RelatorioTipo({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.formato,
    required this.frequencia,
  });

  factory RelatorioTipo.fromJson(Map<String, dynamic> j) => RelatorioTipo(
        id: j['id'].toString(),
        titulo: j['titulo'] as String,
        descricao: j['descricao'] as String,
        formato: FormatoRelatorioX.doJson(j['formato'] as String?),
        frequencia: j['frequencia'] as String,
      );
}

/// Um documento já gerado (lista "Relatórios recentes").
class RelatorioGerado {
  final String id;
  final String titulo;
  final FormatoRelatorio formato;
  final DateTime geradoEm;

  const RelatorioGerado({
    required this.id,
    required this.titulo,
    required this.formato,
    required this.geradoEm,
  });

  factory RelatorioGerado.fromJson(Map<String, dynamic> j) => RelatorioGerado(
        id: j['id'].toString(),
        titulo: j['titulo'] as String,
        formato: FormatoRelatorioX.doJson(j['formato'] as String?),
        geradoEm: DateTime.parse(j['gerado_em'] as String).toLocal(),
      );
}

class RelatoriosData {
  final DateTime? sincronizadoEm;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final List<RelatorioTipo> tipos;
  final List<RelatorioGerado> recentes;

  const RelatoriosData({
    required this.sincronizadoEm,
    this.dataInicio,
    this.dataFim,
    required this.tipos,
    required this.recentes,
  });

  /// Veja o contrato completo em API_CONTRATO.md
  factory RelatoriosData.fromJson(Map<String, dynamic> j) => RelatoriosData(
        sincronizadoEm: null,
        dataInicio: DateTime.parse(j['data_inicio']),
        dataFim: DateTime.parse(j['data_fim']),
        tipos:
            (j['tipos'] as List).map((e) => RelatorioTipo.fromJson(e)).toList(),
        recentes: (j['recentes'] as List)
            .map((e) => RelatorioGerado.fromJson(e))
            .toList(),
      );
}
