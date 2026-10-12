import 'package:flutter/material.dart';

class LegendaItem extends StatelessWidget {
  final Color cor;
  final String texto;
  const LegendaItem({super.key, required this.cor, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 6),
      Text(texto, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
    ]);
  }
}
