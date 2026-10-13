import '../models/filtros.dart';
import '../models/frota_viagens_data.dart';
import 'frota_viagens_repository.dart';
import 'mock_visao_geral_repository.dart';

/// Dados fictícios. Reaproveita o mock da Visão geral (km, viagens, série e linhas)
/// e acrescenta o resumo da frota.
class MockFrotaViagensRepository implements FrotaViagensRepository {
  final _base = MockVisaoGeralRepository();

  @override
  Future<FrotaViagensData> carregar(FiltrosDashboard f) async {
    final v = await _base.carregar(f);
    return FrotaViagensData(
      dataInicio: v.dataInicio,
      dataFim: v.dataFim,
      granularidade: v.granularidade,
      frota: const FrotaResumo(
        total: 142,
        emOperacao: 128,
        emManutencao: 14,
        idadeMedia: 6.2,
        metaIdade: 8,
      ),
      quilometragem: v.quilometragem,
      viagens: v.viagens,
      serie: v.serie,
      linhas: v.linhas,
    );
  }
}
