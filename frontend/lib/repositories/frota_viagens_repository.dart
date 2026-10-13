import '../core/config.dart';
import '../models/filtros.dart';
import '../models/frota_viagens_data.dart';
import 'api_frota_viagens_repository.dart';
import 'mock_frota_viagens_repository.dart';

abstract class FrotaViagensRepository {
  Future<FrotaViagensData> carregar(FiltrosDashboard filtros);
}

/// Escolhe mock ou API conforme --dart-define=USE_MOCK (padrão: mock).
FrotaViagensRepository criarFrotaViagensRepository() =>
    AppConfig.usarMock ? MockFrotaViagensRepository() : ApiFrotaViagensRepository();
