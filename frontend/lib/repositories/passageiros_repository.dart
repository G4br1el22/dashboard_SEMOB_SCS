import '../core/config.dart';
import '../models/chart_data.dart';
import '../models/filtros.dart';
import 'api_passageiros_repository.dart';
import 'mock_passageiros_repository.dart';

class RepositorioException implements Exception {
  final String mensagem;
  RepositorioException(this.mensagem);
  @override
  String toString() => mensagem;
}

/// Contrato que a tela usa. Mock e API implementam o mesmo contrato,
/// então a tela não muda quando o back ficar pronto.
abstract class PassageirosRepository {
  Future<PassageirosData> carregar(FiltrosDashboard filtros);
}

/// Escolhe mock ou API conforme --dart-define=USE_MOCK (padrão: mock).
PassageirosRepository criarPassageirosRepository() =>
    AppConfig.usarMock ? MockPassageirosRepository() : ApiPassageirosRepository();
