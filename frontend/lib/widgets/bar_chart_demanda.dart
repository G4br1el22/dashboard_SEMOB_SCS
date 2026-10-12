import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../models/chart_data.dart';

class BarChartDemanda extends StatelessWidget {
  final List<PontoDemanda> pontos;
  final Granularidade granularidade;
  const BarChartDemanda({super.key, required this.pontos, required this.granularidade});

  static const double _leftSize = 44;
  static const double _bottomSize = 28;

  @override
  Widget build(BuildContext context) {
    final maxValor = pontos.fold<double>(0, (a, p) => max(a, p.total));
    final intervalo = intervaloEixo(maxValor);
    final maxY = max(intervalo, (maxValor / intervalo).ceil() * intervalo);
    final porHora = granularidade == Granularidade.hora;

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
          Text(
            'Distribuição por ${porHora ? 'faixa horária' : 'dia'} — pagantes, não pagantes e viagens',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: pontos.isEmpty
                ? const Center(
                    child: Text('Sem dados para o período selecionado.',
                        style: TextStyle(color: AppColors.textMuted)),
                  )
                : LayoutBuilder(builder: (context, c) {
                    final slot = (c.maxWidth - _leftSize) / pontos.length;
                    final larguraBarra = (slot * 0.62).clamp(3.0, 60.0);
                    return Stack(
                      children: [
                        BarChart(_barData(maxY, intervalo, larguraBarra)),
                        // Linha de viagens sobreposta, alinhada com a área útil das barras
                        Padding(
                          padding: const EdgeInsets.only(left: _leftSize, bottom: _bottomSize),
                          child: IgnorePointer(child: LineChart(_lineData(maxY))),
                        ),
                      ],
                    );
                  }),
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

  BarChartData _barData(double maxY, double intervalo, double larguraBarra) {
    final passoRotulo = max(1, (pontos.length / 12).ceil());
    return BarChartData(
      maxY: maxY,
      minY: 0,
      alignment: BarChartAlignment.spaceAround,
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
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= pontos.length || i % passoRotulo != 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(pontos[i].rotulo, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              );
            },
          ),
        ),
      ),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => const Color(0xFF1A2A45),
          getTooltipItem: (group, _, rod, __) {
            final p = pontos[group.x];
            return BarTooltipItem(
              '${p.rotulo}\n',
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              children: [
                TextSpan(
                    text: 'Pagantes: ${fmtInt(p.pagantes)}\n',
                    style: const TextStyle(color: AppColors.pagantes, fontSize: 11)),
                TextSpan(
                    text: 'Não pagantes: ${fmtInt(p.naoPagantes)}\n',
                    style: const TextStyle(color: AppColors.naoPagantes, fontSize: 11)),
                TextSpan(
                    text: 'Viagens: ${fmtInt(p.viagens)}',
                    style: const TextStyle(color: AppColors.viagens, fontSize: 11)),
              ],
            );
          },
        ),
      ),
      barGroups: [
        for (var i = 0; i < pontos.length; i++)
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: pontos[i].total,
                width: larguraBarra,
                color: Colors.transparent,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                rodStackItems: [
                  BarChartRodStackItem(0, pontos[i].pagantes, AppColors.pagantes),
                  BarChartRodStackItem(pontos[i].pagantes, pontos[i].total, AppColors.naoPagantes),
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
      maxX: pontos.length - 0.5,
      minY: 0,
      maxY: maxY,
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: const FlTitlesData(show: false),
      lineTouchData: const LineTouchData(enabled: false),
      lineBarsData: [
        LineChartBarData(
          spots: [for (var i = 0; i < pontos.length; i++) FlSpot(i.toDouble(), pontos[i].viagens)],
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
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 6),
      Text(texto, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
    ]);
  }
}
