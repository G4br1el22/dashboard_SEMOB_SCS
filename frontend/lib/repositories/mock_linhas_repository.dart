import '../models/filtros.dart';
import '../models/linhas_data.dart';
import 'linhas_repository.dart';
import 'mock_visao_geral_repository.dart';

/// Dados fictícios. Reaproveita as linhas do mock da Visão geral (dia).
class MockLinhasRepository implements LinhasRepository {
  final _base = MockVisaoGeralRepository();

  @override
  Future<LinhasData> carregar() async {
    final v = await _base.carregar(const FiltrosDashboard());
    return LinhasData(
      sincronizadoEm: DateTime.now().subtract(const Duration(minutes: 6)),
      linhas: v.linhas,
    );
  }
}
