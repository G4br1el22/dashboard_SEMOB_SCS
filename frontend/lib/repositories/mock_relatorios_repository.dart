import '../models/relatorios_data.dart';
import 'relatorios_repository.dart';

/// Dados fictícios para desenvolver a UI (os do mockup).
class MockRelatoriosRepository implements RelatoriosRepository {
  static const _tipos = <RelatorioTipo>[
    RelatorioTipo(
      id: 'operacional_diario',
      titulo: 'Relatório operacional diário',
      descricao: 'Quilometragem, viagens e passageiros consolidados do dia.',
      formato: FormatoRelatorio.pdf,
      frequencia: 'Diário',
    ),
    RelatorioTipo(
      id: 'consolidado_semanal',
      titulo: 'Consolidado semanal de demanda',
      descricao: 'Evolução de pagantes e não pagantes por dia da semana.',
      formato: FormatoRelatorio.pdf,
      frequencia: 'Semanal',
    ),
    RelatorioTipo(
      id: 'balanco_mensal',
      titulo: 'Balanço financeiro mensal',
      descricao: 'Receita tarifária, custo operacional e índice de cobertura.',
      formato: FormatoRelatorio.xlsx,
      frequencia: 'Mensal',
    ),
    RelatorioTipo(
      id: 'desempenho_linha',
      titulo: 'Desempenho por linha',
      descricao: 'Ocupação, pontualidade e status de todas as linhas.',
      formato: FormatoRelatorio.xlsx,
      frequencia: 'Sob demanda',
    ),
  ];

  @override
  Future<RelatoriosData> carregar() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return RelatoriosData(
      sincronizadoEm: DateTime.now().subtract(const Duration(minutes: 6)),
      tipos: _tipos,
      recentes: [
        RelatorioGerado(
          id: 'r1',
          titulo: 'Relatório operacional diário',
          formato: FormatoRelatorio.pdf,
          geradoEm: DateTime(2026, 2, 17, 6, 0),
        ),
        RelatorioGerado(
          id: 'r2',
          titulo: 'Consolidado semanal de demanda',
          formato: FormatoRelatorio.pdf,
          geradoEm: DateTime(2026, 2, 16, 23, 30),
        ),
        RelatorioGerado(
          id: 'r3',
          titulo: 'Balanço financeiro mensal',
          formato: FormatoRelatorio.xlsx,
          geradoEm: DateTime(2026, 2, 1, 8, 0),
        ),
      ],
    );
  }

  @override
  Future<RelatorioGerado> gerar(String tipoId) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    final t = _tipos.firstWhere((t) => t.id == tipoId);
    return RelatorioGerado(
      id: 'mock-${DateTime.now().millisecondsSinceEpoch}',
      titulo: t.titulo,
      formato: t.formato,
      geradoEm: DateTime.now(),
    );
  }

  @override
  Uri? urlDownload(RelatorioGerado relatorio) => null; // sem arquivo real no mock
}
