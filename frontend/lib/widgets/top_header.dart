import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/theme.dart';
import '../models/filtros.dart';

class TopHeader extends StatelessWidget {
  final String titulo;
  final DateTime dataReferencia;
  final Periodo periodo;
  final ValueChanged<Periodo> onPeriodo;
  final bool apenasDiasUteis;
  final ValueChanged<bool> onDiasUteis;

  const TopHeader({
    super.key,
    required this.titulo,
    required this.dataReferencia,
    required this.periodo,
    required this.onPeriodo,
    required this.apenasDiasUteis,
    required this.onDiasUteis,
  });

  String get _dataFmt {
    final dia = DateFormat('EEEE', 'pt_BR').format(dataReferencia).split('-').first;
    final cap = dia[0].toUpperCase() + dia.substring(1);
    return '$cap, ${DateFormat("d 'de' MMMM 'de' y", 'pt_BR').format(dataReferencia)} · dados do dia anterior';
  }

  @override
  Widget build(BuildContext context) {
    final opcoes = [
      const Icon(Icons.tune, size: 16, color: AppColors.textMuted),
      const Text('Mesmo período de 2025', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      InkWell(
        onTap: () => onDiasUteis(!apenasDiasUteis),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            apenasDiasUteis ? Icons.check_box : Icons.check_box_outline_blank,
            size: 18,
            color: apenasDiasUteis ? Colors.white : AppColors.textMuted,
          ),
          const SizedBox(width: 6),
          const Text('Dias úteis', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ]),
      ),
    ];

    return LayoutBuilder(builder: (context, c) {
      final largo = c.maxWidth >= 820;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 6),
            Expanded(
              child: Text(_dataFmt,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
            ),
          ]),
          const SizedBox(height: 14),
          if (largo)
            Row(children: [
              const Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 10),
              _SegmentedPeriodo(periodo: periodo, onChanged: onPeriodo),
              const Spacer(),
              Wrap(spacing: 12, crossAxisAlignment: WrapCrossAlignment.center, children: opcoes),
            ])
          else ...[
            Row(children: [
              const Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 10),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _SegmentedPeriodo(periodo: periodo, onChanged: onPeriodo),
                ),
              ),
            ]),
            const SizedBox(height: 10),
            Wrap(
              spacing: 14,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: opcoes,
            ),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1),
        ],
      );
    });
  }
}

class _SegmentedPeriodo extends StatelessWidget {
  final Periodo periodo;
  final ValueChanged<Periodo> onChanged;
  const _SegmentedPeriodo({required this.periodo, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final p in Periodo.values)
            GestureDetector(
              onTap: () => onChanged(p),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: p == periodo ? const Color(0xFF1F3355) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  p.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: p == periodo ? Colors.white : AppColors.textMuted,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
