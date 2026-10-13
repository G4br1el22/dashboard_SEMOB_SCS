import '../core/config.dart';
import '../models/linhas_data.dart';
import 'api_linhas_repository.dart';
import 'mock_linhas_repository.dart';

abstract class LinhasRepository {
  Future<LinhasData> carregar();
}

/// Escolhe mock ou API conforme --dart-define=USE_MOCK (padrão: mock).
LinhasRepository criarLinhasRepository() =>
    AppConfig.usarMock ? MockLinhasRepository() : ApiLinhasRepository();
