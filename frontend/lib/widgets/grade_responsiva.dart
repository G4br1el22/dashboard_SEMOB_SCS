import 'package:flutter/material.dart';

/// Distribui os filhos em [colunasLargo] colunas (largo), 2 (médio) ou 1 (estreito).
class GradeResponsiva extends StatelessWidget {
  final List<Widget> children;
  final int colunasLargo;
  const GradeResponsiva({super.key, required this.children, this.colunasLargo = 4});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      const gap = 16.0;
      final cols = c.maxWidth >= 840 ? colunasLargo : (c.maxWidth >= 520 ? 2 : 1);
      final largura = ((c.maxWidth - gap * (cols - 1)) / cols).floorToDouble();
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [for (final w in children) SizedBox(width: largura, child: w)],
      );
    });
  }
}
