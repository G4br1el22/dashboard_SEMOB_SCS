import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/filtros.dart';

class TopHeader extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final int anoReferencia;
  final FiltrosDashboard filtros;
  final ValueChanged<Periodo> onPeriodo;
  final ValueChanged<Comparacao> onComparacao;
  final ValueChanged<bool> onDiasUteis;

  const TopHeader({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.anoReferencia,
    required this.filtros,
    required this.onPeriodo,
    required this.onComparacao,
    required this.onDiasUteis,
  });

  @override
  Widget build(BuildContext context) {
    final opcoes = [
      _ComparacaoMenu(
        atual: filtros.comparacao,
        ano: anoReferencia,
        onSelecionada: onComparacao,
      ),
      InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => onDiasUteis(!filtros.apenasDiasUteis),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(
              filtros.apenasDiasUteis ? Icons.check_box : Icons.check_box_outline_blank,
              size: 18,
              color: filtros.apenasDiasUteis ? Colors.white : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            const Text('Dias úteis', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ]),
        ),
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
              child: Text(subtitulo, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
            ),
          ]),
          const SizedBox(height: 14),
          if (largo)
            Row(children: [
              const Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 10),
              _SegmentedPeriodo(periodo: filtros.periodo, onChanged: onPeriodo),
              const Spacer(),
              Wrap(spacing: 18, crossAxisAlignment: WrapCrossAlignment.center, children: opcoes),
            ])
          else ...[
            Row(children: [
              const Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 10),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _SegmentedPeriodo(periodo: filtros.periodo, onChanged: onPeriodo),
                ),
              ),
            ]),
            const SizedBox(height: 10),
            Wrap(
              spacing: 18,
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

class _ComparacaoMenu extends StatelessWidget {
  final Comparacao atual;
  final int ano;
  final ValueChanged<Comparacao> onSelecionada;
  const _ComparacaoMenu({required this.atual, required this.ano, required this.onSelecionada});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Comparacao>(
      tooltip: 'Comparar com',
      color: const Color(0xFF14233B),
      position: PopupMenuPosition.under,
      onSelected: onSelecionada,
      itemBuilder: (_) => [
        for (final c in Comparacao.values)
          PopupMenuItem<Comparacao>(
            value: c,
            height: 40,
            child: Row(children: [
              Icon(Icons.check, size: 16, color: c == atual ? AppColors.teal : Colors.transparent),
              const SizedBox(width: 8),
              Text(c.rotulo(ano), style: const TextStyle(fontSize: 13)),
            ]),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.tune, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text(atual.rotulo(ano), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const Icon(Icons.keyboard_arrow_down, size: 18),
        ]),
      ),
    );
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
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => onChanged(p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
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
            ),
        ],
      ),
    );
  }
}
