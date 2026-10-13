import '../core/config.dart';
import '../models/filtros.dart';
import '../models/financeiro_data.dart';
import 'api_financeiro_repository.dart';
import 'mock_financeiro_repository.dart';

abstract class FinanceiroRepository {
  Future<FinanceiroData> carregar(FiltrosDashboard filtros);
}

/// Escolhe mock ou API conforme --dart-define=USE_MOCK (padrão: mock).
FinanceiroRepository criarFinanceiroRepository() =>
    AppConfig.usarMock ? MockFinanceiroRepository() : ApiFinanceiroRepository();
