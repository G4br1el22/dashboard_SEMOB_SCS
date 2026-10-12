import '../core/config.dart';
import '../models/filtros.dart';
import '../models/visao_geral_data.dart';
import 'api_visao_geral_repository.dart';
import 'mock_visao_geral_repository.dart';

abstract class VisaoGeralRepository {
  Future<VisaoGeralData> carregar(FiltrosDashboard filtros);
}

/// Escolhe mock ou API conforme --dart-define=USE_MOCK (padrão: mock).
VisaoGeralRepository criarVisaoGeralRepository() =>
    AppConfig.usarMock ? MockVisaoGeralRepository() : ApiVisaoGeralRepository();
