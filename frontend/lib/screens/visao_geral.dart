import 'package:flutter/material.dart';

import '../models/visao_geral_data.dart';
import '../repositories/visao_geral_repository.dart';
import '../widgets/bar_chart_demanda.dart';
import '../widgets/donut_chart_comp.dart';
import '../widgets/kpi_grid.dart';
import '../widgets/tela_com_filtros.dart';

class VisaoGeralScreen extends StatelessWidget {
  /// Opcional (útil em testes). Se nulo, usa mock ou API conforme AppConfig.
  final VisaoGeralRepository? repository;
  const VisaoGeralScreen({super.key, this.repository});

  // Mesma ordem de VisaoGeralData.kpis
  static const _icones = <IconData>[
    Icons.speed,
    Icons.directions_bus_outlined,
    Icons.people_outline,
    Icons.person_off_outlined,
    Icons.show_chart,
    Icons.account_balance_wallet_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? criarVisaoGeralRepository();
    return TelaComFiltros<VisaoGeralData>(
      titulo: 'Dashboard de Operação de Transporte',
      carregar: repo.carregar,
      intervalo: (d) => (d.dataInicio, d.dataFim),
      alturaMinimaLargo: 840,
      corpoLargo: _corpoLargo,
      corpoEmpilhado: _corpoEmpilhado,
    );
  }

  Widget _corpoLargo(VisaoGeralData d) {
    return Column(
      children: [
        KpiGrid(kpis: d.kpis, icones: _icones),
        const SizedBox(height: 22),
        Expanded(
          child: Row(
            children: [
              Expanded(flex: 2, child: BarChartDemanda(pontos: d.serie, granularidade: d.granularidade)),
              const SizedBox(width: 22),
              Expanded(
                child: DonutChartComp(pagantes: d.pagantes.valor, naoPagantes: d.naoPagantes.valor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _corpoEmpilhado(VisaoGeralData d) {
    return Column(
      children: [
        KpiGrid(kpis: d.kpis, icones: _icones),
        const SizedBox(height: 16),
        SizedBox(height: 400, child: BarChartDemanda(pontos: d.serie, granularidade: d.granularidade)),
        const SizedBox(height: 16),
        SizedBox(
          height: 420,
          child: DonutChartComp(pagantes: d.pagantes.valor, naoPagantes: d.naoPagantes.valor),
        ),
      ],
    );
  }
}
