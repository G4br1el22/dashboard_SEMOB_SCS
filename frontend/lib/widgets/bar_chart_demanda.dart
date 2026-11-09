import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../models/chart_data.dart';

class BarChartDemanda extends StatelessWidget {
  final List<PontoDemanda> pontos;
  final Granularidade granularidade;
  final bool apenasViagens;
  const BarChartDemanda(
      {super.key,
      required this.pontos,
      required this.granularidade,
      this.apenasViagens = false});
  @override
  Widget build(BuildContext context) {
    final series = apenasViagens
        ? [pontos.map((p) => p.viagens).toList()]
        : [
            pontos.map((p) => p.pagantes).toList(),
            pontos.map((p) => p.naoPagantes).toList()
          ];
    final cores = apenasViagens
        ? [AppColors.teal]
        : [AppColors.pagantes, AppColors.naoPagantes];
    final nomes = apenasViagens ? ['Viagens'] : ['Pagantes', 'Não pagantes'];
    final valores = series.expand((s) => s).whereType<double>().toList();
    final maxV = valores.fold<double>(0, max);
    final intervalo = intervaloEixo(maxV);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(apenasViagens ? 'Viagens realizadas' : 'Demanda de passageiros',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(
            'Distribuição por ${granularidade == Granularidade.hora ? 'hora' : 'dia'} · lacunas não equivalem a zero',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        const SizedBox(height: 20),
        Expanded(
            child: valores.isEmpty
                ? const Center(
                    child: Text('Sem dados para o período selecionado.'))
                : LineChart(LineChartData(
                    minX: 0,
                    maxX: max(1, pontos.length - 1).toDouble(),
                    minY: 0,
                    maxY: max(intervalo, (maxV / intervalo).ceil() * intervalo),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                        drawVerticalLine: false, horizontalInterval: intervalo),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(),
                      rightTitles: const AxisTitles(),
                      leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 46,
                              interval: intervalo,
                              getTitlesWidget: (v, _) => Text(fmtEixo(v),
                                  style: const TextStyle(fontSize: 10)))),
                      bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 1,
                              getTitlesWidget: (v, _) {
                                final i = v.round();
                                if ((v - i).abs() > .01 ||
                                    i < 0 ||
                                    i >= pontos.length ||
                                    i % max(1, (pontos.length / 8).ceil()) !=
                                        0) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(pontos[i].rotulo,
                                        style: const TextStyle(fontSize: 10)));
                              })),
                    ),
                    lineBarsData: [
                      for (var n = 0; n < series.length; n++)
                        LineChartBarData(
                          spots: [
                            for (var i = 0; i < pontos.length; i++)
                              series[n][i] == null
                                  ? FlSpot.nullSpot
                                  : FlSpot(i.toDouble(), series[n][i]!)
                          ],
                          color: cores[n],
                          barWidth: 2,
                          isCurved: false,
                          dotData: FlDotData(show: pontos.length == 1),
                        )
                    ],
                  ))),
        const SizedBox(height: 12),
        Wrap(spacing: 18, children: [
          for (var n = 0; n < nomes.length; n++)
            Text(nomes[n], style: TextStyle(color: cores[n], fontSize: 12))
        ]),
      ]),
    );
  }
}
