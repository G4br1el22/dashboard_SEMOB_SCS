import 'package:flutter/material.dart';

import '../core/format.dart';
import '../models/chart_data.dart';
import '../models/frota_viagens_data.dart';
import '../repositories/frota_viagens_repository.dart';
import '../widgets/bar_chart_demanda.dart';
import '../widgets/grade_responsiva.dart';
import '../widgets/kpi_grid.dart';
import '../widgets/stat_card.dart';
import '../widgets/tabela_linhas.dart';
import '../widgets/tela_com_filtros.dart';

class FrotaViagensScreen extends StatelessWidget {
  /// Opcional (útil em testes). Se nulo, usa mock ou API conforme AppConfig.
  final FrotaViagensRepository? repository;
  const FrotaViagensScreen({super.key, this.repository});

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? criarFrotaViagensRepository();
    return TelaComFiltros<FrotaViagensData>(
      titulo: 'Frota e Viagens',
      carregar: repo.carregar,
      intervalo: (d) => (d.dataInicio, d.dataFim),
      corpoRolavel: _corpo,
    );
  }

  Widget _corpo(FrotaViagensData d, bool largo) {
    final f = d.frota;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GradeResponsiva(
          colunasLargo: 4,
          children: [
            StatCard(
              icone: Icons.directions_bus_outlined,
              titulo: 'Frota total',
              valor: fmtInt(f.total),
              legenda: 'veículos cadastrados',
            ),
            StatCard(
              icone: Icons.check_circle_outline,
              titulo: 'Em operação',
              valor: fmtInt(f.emOperacao),
              legenda: '${fmtPct(f.pctOperacao)} da frota',
            ),
            StatCard(
              icone: Icons.build_outlined,
              titulo: 'Em manutenção',
              valor: fmtInt(f.emManutencao),
              legenda: '${fmtPct(f.pctManutencao)} indisponível',
            ),
            StatCard(
              icone: Icons.timer_outlined,
              titulo: 'Idade média',
              valor: '${fmtDecimal(f.idadeMedia)} anos',
              legenda: 'meta: até ${fmtDecimal(f.metaIdade).replaceAll(',0', '')} anos',
            ),
          ],
        ),
        const SizedBox(height: 22),
        KpiGrid(
          kpis: [d.quilometragem, d.viagens],
          icones: const [Icons.speed, Icons.directions_bus_outlined],
        ),
        const SizedBox(height: 22),
        SizedBox(height: 400, child: BarChartDemanda(pontos: d.serie, granularidade: d.granularidade)),
        const SizedBox(height: 22),
        TabelaLinhas(linhas: d.linhas, diario: d.granularidade == Granularidade.hora),
      ],
    );
  }
}
