import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme.dart';

/// "● Dados sincronizados via Smart Data · há 6 min"
/// Verde se sincronizou há menos de 15 min; laranja se estiver defasado.
class IndicadorSync extends StatelessWidget {
  final DateTime sincronizadoEm;
  const IndicadorSync({super.key, required this.sincronizadoEm});

  @override
  Widget build(BuildContext context) {
    final recente = DateTime.now().difference(sincronizadoEm).inMinutes < 15;
    final cor = recente ? AppColors.teal : AppColors.naoPagantes;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            'Dados sincronizados via Smart Data · ${fmtHa(sincronizadoEm)}',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}
