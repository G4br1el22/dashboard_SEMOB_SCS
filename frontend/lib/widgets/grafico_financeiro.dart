import 'package:flutter/material.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../models/visao_geral_data.dart';

class GraficoFinanceiro extends StatelessWidget {
  final List<PontoFinanceiro> pontos;
  final num? receitaTotal;
  final num? custoTotal;
  const GraficoFinanceiro(
      {super.key,
      required this.pontos,
      required this.receitaTotal,
      required this.custoTotal});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Desempenho financeiro',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        if (receitaTotal == null || custoTotal == null)
          const Text(
              'Receita tarifária e custo operacional indisponíveis na fonte validada. Vendas de créditos não equivalem à receita tarifária.',
              style: TextStyle(color: AppColors.textMuted))
        else
          Text(
              'Receita: R\$ ${fmtDecimal2(receitaTotal)} · Custo: R\$ ${fmtDecimal2(custoTotal)}'),
      ]));
}
