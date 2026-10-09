import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme.dart';

class DonutChartComp extends StatelessWidget {
  final num pagantes;
  final num naoPagantes;
  const DonutChartComp({super.key, required this.pagantes, required this.naoPagantes});

  @override
  Widget build(BuildContext context) {
    final total = pagantes + naoPagantes;
    final pctNao = total == 0 ? 0.0 : naoPagantes / total * 100;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Composição de demanda', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Pagantes x não pagantes no período',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 170,
                height: 170,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        startDegreeOffset: 0,
                        sectionsSpace: 0,
                        centerSpaceRadius: 66,
                        pieTouchData: PieTouchData(enabled: false),
                        sections: [
                          PieChartSectionData(
                            value: naoPagantes.toDouble(),
                            color: AppColors.naoPagantes,
                            radius: 18,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: pagantes.toDouble(),
                            color: AppColors.pagantes,
                            radius: 18,
                            showTitle: false,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(fmtMil(total), style: monoStyle(size: 22)),
                        const Text('passageiros', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          LayoutBuilder(builder: (context, c) {
            final a = _Resumo(cor: AppColors.pagantes, rotulo: 'Pagantes', valor: fmtMil(pagantes));
            final b = _Resumo(
              cor: AppColors.naoPagantes,
              rotulo: 'Não pagantes',
              valor: fmtMil(naoPagantes),
              extra: '(${fmtPct(pctNao)})',
            );
            if (c.maxWidth < 330) {
              return Column(children: [a, const SizedBox(height: 10), b]);
            }
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [Expanded(child: a), const SizedBox(width: 12), Expanded(child: b)],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Resumo extends StatelessWidget {
  final Color cor;
  final String rotulo;
  final String valor;
  final String? extra;
  const _Resumo({required this.cor, required this.rotulo, required this.valor, this.extra});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(rotulo, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ]),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Text(valor, style: monoStyle(size: 16)),
              if (extra != null)
                Text(extra!, style: monoStyle(size: 10, weight: FontWeight.w400, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
