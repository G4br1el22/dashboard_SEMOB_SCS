import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/linhas_data.dart';
import '../repositories/linhas_repository.dart';
import '../widgets/grade_responsiva.dart';
import '../widgets/indicador_sync.dart';
import '../widgets/stat_card.dart';
import '../widgets/tabela_linhas.dart';
import '../widgets/tela_simples.dart';

class LinhasScreen extends StatelessWidget {
  /// Opcional (útil em testes). Se nulo, usa mock ou API conforme AppConfig.
  final LinhasRepository? repository;
  const LinhasScreen({super.key, this.repository});

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? criarLinhasRepository();
    return TelaSimples<LinhasData>(
      titulo: 'Linhas',
      subtitulo: 'Desempenho operacional por linha',
      carregar: repo.carregar,
      indicadorDireita: (d) => IndicadorSync(sincronizadoEm: d.sincronizadoEm),
      corpo: _corpo,
    );
  }

  String _pct(double v) => '${v.round()}% das linhas';

  Widget _corpo(LinhasData d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GradeResponsiva(
          colunasLargo: 4,
          children: [
            StatCard(
              titulo: 'Linhas monitoradas',
              valor: '${d.total}',
              legenda: 'total em operação',
            ),
            StatCard(
              cor: AppColors.teal,
              titulo: 'Linhas normais',
              valor: '${d.normais}',
              legenda: _pct(d.pct(d.normais)),
            ),
            StatCard(
              cor: AppColors.naoPagantes,
              titulo: 'Em atenção',
              valor: '${d.atencao}',
              legenda: _pct(d.pct(d.atencao)),
            ),
            StatCard(
              cor: AppColors.viagens,
              titulo: 'Críticas',
              valor: '${d.criticas}',
              legenda: _pct(d.pct(d.criticas)),
            ),
          ],
        ),
        const SizedBox(height: 22),
        TabelaLinhas(linhas: d.linhas, diario: true),
      ],
    );
  }
}
