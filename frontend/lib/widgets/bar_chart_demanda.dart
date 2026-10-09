import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../models/chart_data.dart';

class BarChartDemanda extends StatelessWidget {
  final List<FaixaHoraria> faixas;
  const BarChartDemanda({super.key, required this.faixas});

  static const double _leftSize = 44;
  static const double _bottomSize = 28;

  double get _maxY {
    final m = faixas.map((f) => f.total).fold<double>(0, (a, b) => a > b ? a : b);
    return ((m / 3000).ceil() * 3000).clamp(3000, double.infinity).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final maxY = _maxY;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Demanda de passageiros', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text(
            'Distribuição por faixa horária — pagantes, não pagantes e viagens',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Stack(
              children: [
                LayoutBuilder(builder: (context, c) {
                  final slot = (c.maxWidth - _leftSize) / faixas.length;
                  final larguraBarra = (slot * 0.62).clamp(6.0, 60.0);
                  return Stack(
                    children: [
                      BarChart(_barData(maxY, larguraBarra)),
                      // Linha de viagens sobreposta, alinhada com a área útil das barras
                      Padding(
                        padding: const EdgeInsets.only(left: _leftSize, bottom: _bottomSize),
                        child: IgnorePointer(child: LineChart(_lineData(maxY))),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 6,
            children: [
              _Legenda(cor: AppColors.naoPagantes, texto: 'Não pagantes'),
              _Legenda(cor: AppColors.pagantes, texto: 'Pagantes'),
              _Legenda(cor: AppColors.viagens, texto: 'Viagens'),
            ],
          ),
        ],
      ),
    );
  }

  BarChartData _barData(double maxY, double larguraBarra) {
    return BarChartData(
      maxY: maxY,
      minY: 0,
      alignment: BarChartAlignment.spaceAround,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        drawVerticalLine: false,
        horizontalInterval: 3000,
        getDrawingHorizontalLine: (_) =>
            const FlLine(color: AppColors.border, strokeWidth: 1, dashArray: [4, 4]),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(),
        rightTitles: const AxisTitles(),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: _leftSize,
            interval: 3000,
            getTitlesWidget: (v, _) => Align(
              alignment: Alignment.centerLeft,
              child: Text(fmtEixo(v), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: _bottomSize,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= faixas.length) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(faixas[i].rotulo, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              );
            },
          ),
        ),
      ),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => const Color(0xFF1A2A45),
          getTooltipItem: (group, _, rod, __) {
            final f = faixas[group.x];
            return BarTooltipItem(
              '${f.rotulo}\n',
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              children: [
                TextSpan(
                    text: 'Pagantes: ${fmtInt(f.pagantes)}\n',
                    style: const TextStyle(color: AppColors.pagantes, fontSize: 11)),
                TextSpan(
                    text: 'Não pagantes: ${fmtInt(f.naoPagantes)}\n',
                    style: const TextStyle(color: AppColors.naoPagantes, fontSize: 11)),
                TextSpan(
                    text: 'Viagens: ${fmtInt(f.viagens)}',
                    style: const TextStyle(color: AppColors.viagens, fontSize: 11)),
              ],
            );
          },
        ),
      ),
      barGroups: [
        for (var i = 0; i < faixas.length; i++)
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: faixas[i].total,
                width: larguraBarra,
                color: Colors.transparent,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                rodStackItems: [
                  BarChartRodStackItem(0, faixas[i].pagantes, AppColors.pagantes),
                  BarChartRodStackItem(faixas[i].pagantes, faixas[i].total, AppColors.naoPagantes),
                ],
              ),
            ],
          ),
      ],
    );
  }

  LineChartData _lineData(double maxY) {
    return LineChartData(
      minX: -0.5,
      maxX: faixas.length - 0.5,
      minY: 0,
      maxY: maxY,
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: const FlTitlesData(show: false),
      lineTouchData: const LineTouchData(enabled: false),
      lineBarsData: [
        LineChartBarData(
          spots: [for (var i = 0; i < faixas.length; i++) FlSpot(i.toDouble(), faixas[i].viagens)],
          isCurved: true,
          color: AppColors.viagens,
          barWidth: 1.5,
          dotData: const FlDotData(show: false),
        ),
      ],
    );
  }
}

class _Legenda extends StatelessWidget {
  final Color cor;
  final String texto;
  const _Legenda({required this.cor, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 6),
      Text(texto, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
    ]);
  }
}
