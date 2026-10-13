import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Cartão simples: título (com ícone opcional), valor grande e legenda embaixo.
/// Sem ícone o cartão fica mais baixo (como nos indicadores do Financeiro).
class StatCard extends StatelessWidget {
  final IconData? icone;
  final String titulo;
  final String valor;
  final String legenda;

  /// Se informada, mostra uma bolinha antes do título e pinta o valor com essa cor.
  final Color? cor;

  const StatCard({
    super.key,
    this.icone,
    this.cor,
    required this.titulo,
    required this.valor,
    required this.legenda,
  });

  @override
  Widget build(BuildContext context) {
    final temIcone = icone != null;
    return Container(
      height: temIcone ? 146 : 126,
      padding: EdgeInsets.fromLTRB(20, temIcone ? 18 : 16, 20, 16),
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
              if (temIcone) ...[
                Container(
                  width: 36,
                  height: 36,
                  decoration:
                      BoxDecoration(color: const Color(0xFF16253F), borderRadius: BorderRadius.circular(8)),
                  child: Icon(icone, size: 18, color: AppColors.pagantes),
                ),
                const SizedBox(width: 12),
              ],
              if (cor != null) ...[
                Container(width: 8, height: 8, decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13.5, color: Color(0xFFD5DEEC))),
              ),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(valor, style: monoStyle(size: 26, color: cor)),
          ),
          const SizedBox(height: 6),
          Text(legenda,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
