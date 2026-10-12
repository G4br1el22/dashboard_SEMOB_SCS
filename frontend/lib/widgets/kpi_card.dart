import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../models/kpi_model.dart';

class KpiCard extends StatelessWidget {
  final KpiModel kpi;
  final IconData icone;
  const KpiCard({super.key, required this.kpi, required this.icone});

  String get _valor => switch (kpi.formato) {
        KpiFormato.inteiro => fmtInt(kpi.valor),
        KpiFormato.km => '${fmtInt(kpi.valor)} km',
        KpiFormato.moeda => 'R\$ ${fmtInt(kpi.valor)}',
      };

  @override
  Widget build(BuildContext context) {
    final v = kpi.variacaoPercentual;
    final subiu = (v ?? 0) >= 0;
    final bom = v == null ? true : subiu == kpi.altaEhBoa;
    final cor = bom ? AppColors.teal : AppColors.viagens;

    return LayoutBuilder(builder: (context, c) {
      final mostraSpark = c.maxWidth > 330;
      return Container(
        height: 126,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration:
                      BoxDecoration(color: const Color(0xFF16253F), borderRadius: BorderRadius.circular(8)),
                  child: Icon(icone, size: 18, color: AppColors.pagantes),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(kpi.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13.5, color: Color(0xFFD5DEEC))),
                ),
                if (mostraSpark) ...[
                  const SizedBox(width: 8),
                  SizedBox(width: 100, height: 34, child: _Sparkline(valores: kpi.sparkline, cor: cor)),
                ],
              ],
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(_valor, style: monoStyle(size: 26)),
                  ),
                ),
                const SizedBox(width: 8),
                if (v != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: cor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${subiu ? '↗' : '↘'} ${v.abs().toStringAsFixed(1).replaceAll('.', ',')}%',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: cor),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _Sparkline extends StatelessWidget {
  final List<double> valores;
  final Color cor;
  const _Sparkline({required this.valores, required this.cor});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: [for (var i = 0; i < valores.length; i++) FlSpot(i.toDouble(), valores[i])],
            isCurved: false,
            color: cor,
            barWidth: 1.8,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
