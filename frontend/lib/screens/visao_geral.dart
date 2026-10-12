import 'package:flutter/material.dart';

import '../models/chart_data.dart';
import '../models/visao_geral_data.dart';
import '../repositories/visao_geral_repository.dart';
import '../widgets/bar_chart_demanda.dart';
import '../widgets/donut_chart_comp.dart';
import '../widgets/grafico_financeiro.dart';
import '../widgets/kpi_grid.dart';
import '../widgets/tabela_linhas.dart';
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
      corpoRolavel: _corpo,
    );
  }

  Widget _corpo(VisaoGeralData d, bool largo) {
    final demanda = BarChartDemanda(pontos: d.serie, granularidade: d.granularidade);
    final composicao = DonutChartComp(pagantes: d.pagantes.valor, naoPagantes: d.naoPagantes.valor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KpiGrid(kpis: d.kpis, icones: _icones),
        const SizedBox(height: 22),
        if (largo)
          SizedBox(
            height: 400,
            child: Row(
              children: [
                Expanded(flex: 2, child: demanda),
                const SizedBox(width: 22),
                Expanded(child: composicao),
              ],
            ),
          )
        else ...[
          SizedBox(height: 400, child: demanda),
          const SizedBox(height: 16),
          SizedBox(height: 420, child: composicao),
        ],
        SizedBox(height: largo ? 22 : 16),
        GraficoFinanceiro(
          pontos: d.financeiro,
          receitaTotal: d.receita.valor,
          custoTotal: d.custo.valor,
        ),
        SizedBox(height: largo ? 22 : 16),
        TabelaLinhas(linhas: d.linhas, diario: d.granularidade == Granularidade.hora),
      ],
    );
  }
}
