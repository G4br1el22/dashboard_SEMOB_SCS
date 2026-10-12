import 'dart:math';

import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../models/visao_geral_data.dart';

/// "Desempenho por linha". Em telas estreitas a tabela rola na horizontal.
class TabelaLinhas extends StatelessWidget {
  final List<LinhaDesempenho> linhas;
  final bool diario;
  const TabelaLinhas({super.key, required this.linhas, required this.diario});

  static const _wKm = 84.0;
  static const _wViagens = 84.0;
  static const _wPag = 96.0;
  static const _wNao = 96.0;
  static const _wOcup = 96.0;
  static const _wPont = 160.0;
  static const _wStatus = 104.0;
  static const _larguraMinima = 900.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Desempenho por linha', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            'Indicadores operacionais das principais linhas ${diario ? 'do dia' : 'do período'}',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 14),
          if (linhas.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('Sem dados para o período selecionado.',
                    style: TextStyle(color: AppColors.textMuted)),
              ),
            )
          else
            LayoutBuilder(builder: (context, c) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: max(c.maxWidth, _larguraMinima),
                  child: Column(
                    children: [
                      _cabecalho(),
                      for (var i = 0; i < linhas.length; i++) _linha(linhas[i], ultima: i == linhas.length - 1),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  static const _bordaInferior = BoxDecoration(
    border: Border(bottom: BorderSide(color: AppColors.border)),
  );

  Widget _celulaNum(String t, double w) => SizedBox(
        width: w,
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(t, style: monoStyle(size: 13, weight: FontWeight.w600)),
        ),
      );

  Widget _titulo(String t, double w, {Alignment alin = Alignment.centerRight, double padEsq = 0}) => SizedBox(
        width: w,
        child: Padding(
          padding: EdgeInsets.only(left: padEsq),
          child: Align(
            alignment: alin,
            child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ),
      );

  Widget _cabecalho() => Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: _bordaInferior,
        child: Row(
          children: [
            const Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text('Linha', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
            _titulo('Km', _wKm),
            _titulo('Viagens', _wViagens),
            _titulo('Pagantes', _wPag),
            _titulo('Não pag.', _wNao),
            _titulo('Ocupação', _wOcup),
            _titulo('Pontualidade', _wPont, alin: Alignment.centerLeft, padEsq: 16),
            _titulo('Status', _wStatus),
            const SizedBox(width: 8),
          ],
        ),
      );

  Color _corPontualidade(double p) => p >= 90 ? AppColors.teal : (p >= 80 ? AppColors.naoPagantes : AppColors.viagens);

  Widget _linha(LinhaDesempenho l, {required bool ultima}) {
    final corPont = _corPontualidade(l.pontualidade);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: ultima ? null : _bordaInferior,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                children: [
                  Container(
                    constraints: const BoxConstraints(minWidth: 36),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(6)),
                    child: Center(
                      child: Text(l.codigo,
                          style: monoStyle(size: 11, color: const Color(0xFF0A1424))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(l.nome,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
          ),
          _celulaNum(fmtInt(l.km), _wKm),
          _celulaNum(fmtInt(l.viagens), _wViagens),
          _celulaNum(fmtInt(l.pagantes), _wPag),
          _celulaNum(fmtInt(l.naoPagantes), _wNao),
          _celulaNum('${l.ocupacao.round()}%', _wOcup),
          SizedBox(
            width: _wPont,
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 5,
                    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(3)),
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: (l.pontualidade / 100).clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(color: corPont, borderRadius: BorderRadius.circular(3)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${l.pontualidade.round()}%',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
          SizedBox(
            width: _wStatus,
            child: Align(alignment: Alignment.centerRight, child: _StatusChip(status: l.status)),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final StatusLinha status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (texto, cor) = switch (status) {
      StatusLinha.normal => ('Normal', AppColors.teal),
      StatusLinha.atencao => ('Atenção', AppColors.naoPagantes),
      StatusLinha.critico => ('Crítico', AppColors.viagens),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cor.withOpacity(0.55)),
      ),
      child: Text(texto, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cor)),
    );
  }
}
