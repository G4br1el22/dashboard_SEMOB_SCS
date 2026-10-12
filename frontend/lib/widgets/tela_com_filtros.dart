import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../models/filtros.dart';
import 'top_header.dart';

/// Esqueleto comum das telas do dashboard: cabeçalho com filtros, carregamento,
/// erro com "tentar novamente" e layout responsivo.
///
/// Dois modos (informe um deles):
///  * [corpoRolavel]: cabeçalho fixo no topo e só o conteúdo rola (Visão geral).
///    Recebe `largo` (true quando há largura para colocar gráficos lado a lado).
///  * [corpoLargo] + [corpoEmpilhado]: largo = tudo cabe na tela sem rolar;
///    estreito = empilhado com rolagem (Passageiros).
class TelaComFiltros<T> extends StatefulWidget {
  final String titulo;
  final Future<T> Function(FiltrosDashboard filtros) carregar;
  final (DateTime, DateTime) Function(T dados) intervalo;

  final Widget Function(T dados, bool largo)? corpoRolavel;
  final Widget Function(T dados)? corpoLargo;
  final Widget Function(T dados)? corpoEmpilhado;

  /// Altura mínima da janela para usar o modo largo (só modo corpoLargo).
  final double alturaMinimaLargo;

  const TelaComFiltros({
    super.key,
    required this.titulo,
    required this.carregar,
    required this.intervalo,
    this.corpoRolavel,
    this.corpoLargo,
    this.corpoEmpilhado,
    this.alturaMinimaLargo = 640,
  }) : assert(
          corpoRolavel != null || (corpoLargo != null && corpoEmpilhado != null),
          'Informe corpoRolavel OU (corpoLargo e corpoEmpilhado)',
        );

  @override
  State<TelaComFiltros<T>> createState() => _TelaComFiltrosState<T>();
}

class _TelaComFiltrosState<T> extends State<TelaComFiltros<T>> {
  static const _rodape =
      'SEMOB · Secretaria de Mobilidade Urbana de São Caetano do Sul · Instituto Mauá de Tecnologia · TTI206 · 2026-2';

  FiltrosDashboard _filtros = const FiltrosDashboard();
  T? _data;
  Object? _erro;
  bool _carregando = true;
  int _requisicao = 0; // evita que uma resposta antiga sobrescreva a mais nova

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final id = ++_requisicao;
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final d = await widget.carregar(_filtros);
      if (!mounted || id != _requisicao) return;
      setState(() {
        _data = d;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted || id != _requisicao) return;
      setState(() {
        _erro = e;
        _carregando = false;
      });
    }
  }

  void _aplicar(FiltrosDashboard novos) {
    _filtros = novos;
    _carregar();
  }

  Future<void> _escolherPeriodo(Periodo p) async {
    if (p != Periodo.datas) {
      _aplicar(_filtros.copyWith(periodo: p));
      return;
    }
    final hoje = DateTime.now();
    DateTimeRange? atual = _filtros.intervalo;
    final d = _data;
    if (atual == null && d != null) {
      final (ini, fim) = widget.intervalo(d);
      atual = DateTimeRange(start: ini, end: fim);
    }
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(hoje.year, hoje.month, hoje.day),
      initialDateRange: atual,
      locale: const Locale('pt', 'BR'),
      helpText: 'Selecione o período',
      saveText: 'Aplicar',
    );
    if (r == null) return;
    _aplicar(_filtros.copyWith(periodo: Periodo.datas, intervalo: r));
  }

  @override
  Widget build(BuildContext context) {
    final d = _data;
    String subtitulo = '';
    int ano = DateTime.now().year;
    if (d != null) {
      final (ini, fim) = widget.intervalo(d);
      subtitulo = fmtSubtitulo(ini, fim, _filtros.periodo);
      ano = fim.year;
    }

    final header = TopHeader(
      titulo: widget.titulo,
      subtitulo: subtitulo,
      anoReferencia: ano,
      filtros: _filtros,
      onPeriodo: _escolherPeriodo,
      onComparacao: (c) => _aplicar(_filtros.copyWith(comparacao: c)),
      onDiasUteis: (v) => _aplicar(_filtros.copyWith(apenasDiasUteis: v)),
    );

    return LayoutBuilder(builder: (context, c) {
      final pad = c.maxWidth < 700 ? 16.0 : 32.0;
      final larguraUtil = c.maxWidth - pad * 2;

      if (widget.corpoRolavel != null) {
        return _layoutRolavel(header, pad, larguraUtil >= 900);
      }
      final largo = larguraUtil >= 900 && c.maxHeight >= widget.alturaMinimaLargo;
      return Padding(
        padding: EdgeInsets.fromLTRB(pad, 24, pad, 16),
        child: largo ? _layoutLargo(header) : _layoutEmpilhado(header),
      );
    });
  }

  Widget _barraCarregando() => SizedBox(
        height: 2,
        child: _carregando ? const LinearProgressIndicator(minHeight: 2) : null,
      );

  static const _textoRodape = Text(
    _rodape,
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
  );

  // Cabeçalho fixo + conteúdo que rola.
  Widget _layoutRolavel(Widget header, double pad, bool largo) {
    final d = _data;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(pad, 24, pad, 0),
          child: Column(children: [header, _barraCarregando()]),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(pad, 22, pad, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (d == null || _erro != null)
                  SizedBox(height: 300, child: _estado((_) => const SizedBox()))
                else
                  widget.corpoRolavel!(d, largo),
                const SizedBox(height: 20),
                _textoRodape,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _layoutLargo(Widget header) {
    return Column(
      children: [
        header,
        _barraCarregando(),
        const SizedBox(height: 22),
        Expanded(child: _estado(widget.corpoLargo!)),
        const SizedBox(height: 12),
        _textoRodape,
      ],
    );
  }

  Widget _layoutEmpilhado(Widget header) {
    final d = _data;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          _barraCarregando(),
          const SizedBox(height: 22),
          if (d == null || _erro != null)
            SizedBox(height: 220, child: _estado((_) => const SizedBox()))
          else
            widget.corpoEmpilhado!(d),
          const SizedBox(height: 16),
          _textoRodape,
        ],
      ),
    );
  }

  Widget _estado(Widget Function(T) builder) {
    if (_erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 36, color: AppColors.textMuted),
            const SizedBox(height: 10),
            Text('$_erro', style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _carregar,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    final d = _data;
    if (d == null) return const Center(child: CircularProgressIndicator());
    return builder(d);
  }
}
