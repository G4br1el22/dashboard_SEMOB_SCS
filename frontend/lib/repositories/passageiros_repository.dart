import '../models/chart_data.dart';
import '../models/filtros.dart';
import '../models/kpi_model.dart';

/// Contrato que a tela usa. Quando o back estiver pronto, crie
/// `ApiPassageirosRepository` (Dio -> FastAPI) e troque em PassageirosScreen.
abstract class PassageirosRepository {
  Future<PassageirosData> carregar({
    required Periodo periodo,
    required bool compararAnoAnterior,
    required bool apenasDiasUteis,
  });
}

/// Dados fictícios só para desenvolver a UI.
class MockPassageirosRepository implements PassageirosRepository {
  @override
  Future<PassageirosData> carregar({
    required Periodo periodo,
    required bool compararAnoAnterior,
    required bool apenasDiasUteis,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    const faixas = <FaixaHoraria>[
      FaixaHoraria(rotulo: '04h', pagantes: 900, naoPagantes: 250, viagens: 60),
      FaixaHoraria(rotulo: '06h', pagantes: 5300, naoPagantes: 1500, viagens: 140),
      FaixaHoraria(rotulo: '08h', pagantes: 8000, naoPagantes: 3200, viagens: 190),
      FaixaHoraria(rotulo: '10h', pagantes: 4400, naoPagantes: 1700, viagens: 120),
      FaixaHoraria(rotulo: '12h', pagantes: 5100, naoPagantes: 2000, viagens: 130),
      FaixaHoraria(rotulo: '14h', pagantes: 4000, naoPagantes: 1500, viagens: 110),
      FaixaHoraria(rotulo: '16h', pagantes: 4800, naoPagantes: 1800, viagens: 125),
      FaixaHoraria(rotulo: '18h', pagantes: 6900, naoPagantes: 2400, viagens: 160),
      FaixaHoraria(rotulo: '20h', pagantes: 2100, naoPagantes: 800, viagens: 80),
      FaixaHoraria(rotulo: '22h', pagantes: 500, naoPagantes: 300, viagens: 40),
    ];

    return PassageirosData(
      dataReferencia: DateTime(2026, 2, 17),
      pagantes: const KpiModel(
        titulo: 'Passageiros pagantes',
        valor: 42380,
        variacaoPercentual: 3.1,
        sparkline: [3, 5, 4, 6, 4.5, 7, 7.6, 8],
      ),
      naoPagantes: const KpiModel(
        titulo: 'Passageiros não pagantes',
        valor: 15910,
        variacaoPercentual: 5.8,
        sparkline: [3, 4.5, 5, 4.6, 5.8, 6.2, 7.2, 8],
      ),
      faixas: faixas,
    );
  }
}
