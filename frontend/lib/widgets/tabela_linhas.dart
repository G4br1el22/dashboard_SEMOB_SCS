import 'package:flutter/material.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../models/visao_geral_data.dart';

class TabelaLinhas extends StatelessWidget {
  final List<LinhaDesempenho> linhas;
  final bool diario;
  const TabelaLinhas({super.key, required this.linhas, required this.diario});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Desempenho por linha',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text(
            '— indica informação indisponível. Ocupação e pontualidade não têm fonte validada.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
        const SizedBox(height: 14),
        if (linhas.isEmpty)
          const Text('Sem dados para o período selecionado.')
        else
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  for (final label in [
                    'Linha',
                    'Km',
                    'Viagens',
                    'Pagantes',
                    'Não pagantes',
                    'Ocupação',
                    'Pontualidade'
                  ])
                    DataColumn(label: Text(label))
                ],
                rows: [
                  for (final l in linhas)
                    DataRow(cells: [
                      DataCell(Text(l.codigo)),
                      DataCell(Text(fmtDecimal2(l.km))),
                      DataCell(Text(fmtInt(l.viagens))),
                      DataCell(Text(fmtInt(l.pagantes))),
                      DataCell(Text(fmtInt(l.naoPagantes))),
                      DataCell(Text(fmtPct(l.ocupacao))),
                      DataCell(Text(fmtPct(l.pontualidade)))
                    ])
                ],
              )),
      ]));
}
