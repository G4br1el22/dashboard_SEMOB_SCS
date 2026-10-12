import 'package:flutter/material.dart';

import '../models/chart_data.dart';
import '../repositories/passageiros_repository.dart';
import '../widgets/bar_chart_demanda.dart';
import '../widgets/donut_chart_comp.dart';
import '../widgets/kpi_card.dart';
import '../widgets/tela_com_filtros.dart';

class PassageirosScreen extends StatelessWidget {
  /// Opcional (útil em testes). Se nulo, usa mock ou API conforme AppConfig.
  final PassageirosRepository? repository;
  const PassageirosScreen({super.key, this.repository});

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? criarPassageirosRepository();
    return TelaComFiltros<PassageirosData>(
      titulo: 'Passageiros',
      carregar: repo.carregar,
      intervalo: (d) => (d.dataInicio, d.dataFim),
      alturaMinimaLargo: 640,
      corpoLargo: _corpoLargo,
      corpoEmpilhado: _corpoEmpilhado,
    );
  }

  Widget _kpis(PassageirosData d) => LayoutBuilder(builder: (context, c) {
        final cards = [
          KpiCard(kpi: d.pagantes, icone: Icons.people_outline),
          KpiCard(kpi: d.naoPagantes, icone: Icons.person_off_outlined),
        ];
        if (c.maxWidth < 480) {
          return Column(children: [cards[0], const SizedBox(height: 12), cards[1]]);
        }
        return Row(children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 16),
          Expanded(child: cards[1]),
        ]);
      });

  Widget _corpoLargo(PassageirosData d) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(flex: 2, child: _kpis(d)),
            const SizedBox(width: 22),
            const Expanded(child: SizedBox()),
          ],
        ),
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

  Widget _corpoEmpilhado(PassageirosData d) {
    return Column(
      children: [
        _kpis(d),
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
