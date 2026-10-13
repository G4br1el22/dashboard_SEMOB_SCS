import 'package:flutter/material.dart';

import '../core/format.dart';
import '../models/financeiro_data.dart';
import '../repositories/financeiro_repository.dart';
import '../widgets/grade_responsiva.dart';
import '../widgets/grafico_financeiro.dart';
import '../widgets/kpi_grid.dart';
import '../widgets/stat_card.dart';
import '../widgets/tela_com_filtros.dart';

class FinanceiroScreen extends StatelessWidget {
  /// Opcional (útil em testes). Se nulo, usa mock ou API conforme AppConfig.
  final FinanceiroRepository? repository;
  const FinanceiroScreen({super.key, this.repository});

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? criarFinanceiroRepository();
    return TelaComFiltros<FinanceiroData>(
      titulo: 'Financeiro',
      carregar: repo.carregar,
      intervalo: (d) => (d.dataInicio, d.dataFim),
      corpoRolavel: _corpo,
    );
  }

  String _resultado(num v) => '${v < 0 ? '-' : ''}R\$ ${fmtInt(v.abs())}';

  Widget _corpo(FinanceiroData d, bool largo) {
    final deficit = d.resultado < 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KpiGrid(
          kpis: [d.receita, d.custo],
          icones: const [Icons.show_chart, Icons.account_balance_wallet_outlined],
        ),
        const SizedBox(height: 22),
        GradeResponsiva(
          colunasLargo: 4,
          children: [
            StatCard(
              titulo: 'Resultado operacional',
              valor: _resultado(d.resultado),
              legenda: deficit ? 'déficit no período' : 'superávit no período',
            ),
            StatCard(
              titulo: 'Cobertura tarifária',
              valor: fmtPct(d.cobertura),
              legenda: 'receita ÷ custo',
            ),
            StatCard(
              titulo: 'Custo por passageiro',
              valor: 'R\$ ${fmtDecimal2(d.custoPorPassageiro)}',
              legenda: 'custo ÷ pagantes',
            ),
            StatCard(
              titulo: 'Receita por passageiro',
              valor: 'R\$ ${fmtDecimal2(d.receitaPorPassageiro)}',
              legenda: 'tarifa média realizada',
            ),
          ],
        ),
        const SizedBox(height: 22),
        GraficoFinanceiro(
          pontos: d.financeiro,
          receitaTotal: d.receita.valor,
          custoTotal: d.custo.valor,
        ),
      ],
    );
  }
}
