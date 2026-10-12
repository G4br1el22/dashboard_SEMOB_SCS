import '../models/filtros.dart';
import '../models/kpi_model.dart';
import '../models/visao_geral_data.dart';
import 'mock_passageiros_repository.dart';
import 'visao_geral_repository.dart';

/// Dados fictícios que reagem aos filtros. Reaproveita o mock de passageiros
/// e deriva km, viagens, receita e custo a partir dele.
class MockVisaoGeralRepository implements VisaoGeralRepository {
  final _base = MockPassageirosRepository();

  @override
  Future<VisaoGeralData> carregar(FiltrosDashboard f) async {
    final b = await _base.carregar(f);

    final viagens = (b.serie.fold<double>(0, (a, p) => a + p.viagens) * 1.1117).roundToDouble();
    final km = (viagens * 14.346).roundToDouble();
    final receita = (b.pagantes.valor * 4.4252).roundToDouble();
    final custo = (km * 11.6341).roundToDouble();

    final i = f.periodo.index;
    double? v(List<double> porPeriodo) => switch (f.comparacao) {
          Comparacao.anoAnterior => porPeriodo[i],
          Comparacao.periodoAnterior => -porPeriodo[i] * 0.6,
          Comparacao.nenhuma => null,
        };

    final sparkViagens = b.serie.map((p) => p.viagens).toList();

    return VisaoGeralData(
      dataInicio: b.dataInicio,
      dataFim: b.dataFim,
      granularidade: b.granularidade,
      quilometragem: KpiModel(
        titulo: 'Quilometragem',
        valor: km,
        variacaoPercentual: v(const [2.4, 1.8, 2.1, 3.0, 1.6]),
        sparkline: sparkViagens,
        formato: KpiFormato.km,
      ),
      viagens: KpiModel(
        titulo: 'Viagens realizadas',
        valor: viagens,
        variacaoPercentual: v(const [-1.2, -0.8, 0.6, -1.5, 0.9]),
        sparkline: sparkViagens,
      ),
      pagantes: b.pagantes,
      naoPagantes: b.naoPagantes,
      receita: KpiModel(
        titulo: 'Receita tarifária',
        valor: receita,
        variacaoPercentual: v(const [2.9, 2.2, 1.7, 3.8, 2.5]),
        sparkline: b.pagantes.sparkline,
        formato: KpiFormato.moeda,
      ),
      custo: KpiModel(
        titulo: 'Custo operacional',
        valor: custo,
        variacaoPercentual: v(const [1.4, 1.1, 0.9, 2.0, 1.3]),
        sparkline: sparkViagens,
        formato: KpiFormato.moeda,
        altaEhBoa: false,
      ),
      serie: b.serie,
    );
  }
}
