import '../core/config.dart';
import '../models/relatorios_data.dart';
import 'api_relatorios_repository.dart';
import 'mock_relatorios_repository.dart';

abstract class RelatoriosRepository {
  Future<RelatoriosData> carregar();

  /// Pede ao back para gerar um relatório e devolve o documento criado.
  Future<RelatorioGerado> gerar(String tipoId);

  /// Link de download do documento. null = sem download (modo mock).
  Uri? urlDownload(RelatorioGerado relatorio);
}

/// Escolhe mock ou API conforme --dart-define=USE_MOCK (padrão: mock).
RelatoriosRepository criarRelatoriosRepository() =>
    AppConfig.usarMock ? MockRelatoriosRepository() : ApiRelatoriosRepository();
