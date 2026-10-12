import 'package:flutter/material.dart';

import '../models/kpi_model.dart';
import 'kpi_card.dart';

/// Grade responsiva de cartões: 3 colunas (largo), 2 (médio) ou 1 (estreito).
class KpiGrid extends StatelessWidget {
  final List<KpiModel> kpis;
  final List<IconData> icones;
  const KpiGrid({super.key, required this.kpis, required this.icones});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      const gap = 16.0;
      final cols = c.maxWidth >= 840 ? 3 : (c.maxWidth >= 520 ? 2 : 1);
      final largura = ((c.maxWidth - gap * (cols - 1)) / cols).floorToDouble();
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (var i = 0; i < kpis.length; i++)
            SizedBox(width: largura, child: KpiCard(kpi: kpis[i], icone: icones[i])),
        ],
      );
    });
  }
}
