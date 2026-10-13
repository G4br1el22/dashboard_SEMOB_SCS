import '../models/filtros.dart';
import '../models/financeiro_data.dart';
import 'financeiro_repository.dart';
import 'mock_visao_geral_repository.dart';

/// Dados fictícios. Reaproveita o mock da Visão geral (receita, custo e série financeira).
class MockFinanceiroRepository implements FinanceiroRepository {
  final _base = MockVisaoGeralRepository();

  @override
  Future<FinanceiroData> carregar(FiltrosDashboard f) async {
    final v = await _base.carregar(f);
    return FinanceiroData(
      dataInicio: v.dataInicio,
      dataFim: v.dataFim,
      granularidade: v.granularidade,
      receita: v.receita,
      custo: v.custo,
      pagantes: v.pagantes.valor,
      financeiro: v.financeiro,
    );
  }
}
