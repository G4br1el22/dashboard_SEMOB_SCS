import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../models/visao_geral_data.dart';
import 'legenda_item.dart';

/// "Desempenho financeiro": custo operacional x receita tarifária.
class GraficoFinanceiro extends StatelessWidget {
  final List<PontoFinanceiro> pontos;
  final num receitaTotal;
  final num custoTotal;

  const GraficoFinanceiro({
    super.key,
    required this.pontos,
    required this.receitaTotal,
    required this.custoTotal,
  });

  static const double _leftSize = 44;
  static const double _bottomSize = 28;

  String get _subtitulo {
    if (custoTotal == 0) return 'Sem custo registrado no período';
    final indice = (receitaTotal / custoTotal * 100).round();
    final saldo = receitaTotal - custoTotal;
    final texto = saldo >= 0 ? 'superávit' : 'déficit';
    return 'Índice de cobertura tarifária de $indice% · $texto de R\$ ${fmtInt(saldo.abs())}';
  }

  @override
  Widget build(BuildContext context) {
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
          const Text('Desempenho financeiro', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(_subtitulo, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: pontos.isEmpty
                ? const Center(
                    child: Text('Sem dados para o período selecionado.',
                        style: TextStyle(color: AppColors.textMuted)),
                  )
                : LineChart(_dados()),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                LegendaItem(cor: AppColors.viagens, texto: 'Custo operacional'),
                LegendaItem(cor: AppColors.teal, texto: 'Receita tarifária'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _linha(List<double> valores, Color cor, double opacidadeArea) {
    return LineChartBarData(
      spots: [for (var i = 0; i < valores.length; i++) FlSpot(i.toDouble(), valores[i])],
      isCurved: true,
      curveSmoothness: 0.3,
      preventCurveOverShooting: true,
      color: cor,
      barWidth: 2,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [cor.withOpacity(opacidadeArea), cor.withOpacity(0)],
        ),
      ),
    );
  }

  LineChartData _dados() {
    final maxV = pontos.fold<double>(0, (a, p) => max(a, max(p.receita, p.custo)));
    final intervalo = intervaloEixo(maxV);
    final maxY = max(intervalo, (maxV / intervalo).ceil() * intervalo);
    final passoRotulo = max(1, (pontos.length / 12).ceil());

    return LineChartData(
      minX: 0,
      maxX: max(1, pontos.length - 1).toDouble(),
      minY: 0,
      maxY: maxY,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        drawVerticalLine: false,
        horizontalInterval: intervalo,
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
            interval: intervalo,
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
            interval: 1,
            getTitlesWidget: (v, _) {
              final i = v.round();
              if ((v - i).abs() > 0.01 || i < 0 || i >= pontos.length || i % passoRotulo != 0) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(pontos[i].rotulo, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              );
            },
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => const Color(0xFF1A2A45),
          getTooltipItems: (spots) => [
            for (final s in spots)
              LineTooltipItem(
                '${s.barIndex == 0 ? 'Custo' : 'Receita'}: R\$ ${fmtInt(s.y)}',
                TextStyle(
                  color: s.barIndex == 0 ? AppColors.viagens : AppColors.teal,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
      lineBarsData: [
        _linha(pontos.map((p) => p.custo).toList(), AppColors.viagens, 0.18), // index 0
        _linha(pontos.map((p) => p.receita).toList(), AppColors.teal, 0.22), // index 1
      ],
    );
  }
}
