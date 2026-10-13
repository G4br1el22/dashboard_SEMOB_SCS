import 'dart:async';

import 'package:flutter/material.dart';

import '../core/textos.dart';
import '../core/theme.dart';

/// Esqueleto para telas SEM filtros de período (ex.: Linhas):
/// cabeçalho fixo (título, subtítulo e um indicador à direita) + conteúdo que rola.
/// Recarrega sozinho a cada [atualizarACadaMin] minutos (sem piscar a tela) e
/// redesenha a cada minuto para manter textos como "há 6 min" corretos.
class TelaSimples<T> extends StatefulWidget {
  final String titulo;
  final String subtitulo;
  final Future<T> Function() carregar;
  final Widget Function(T dados) corpo;

  /// Aparece abaixo do título, alinhado à direita.
  final Widget Function(T dados)? indicadorDireita;
  final int atualizarACadaMin;

  const TelaSimples({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.carregar,
    required this.corpo,
    this.indicadorDireita,
    this.atualizarACadaMin = 5,
  });

  @override
  State<TelaSimples<T>> createState() => _TelaSimplesState<T>();
}

class _TelaSimplesState<T> extends State<TelaSimples<T>> {
  T? _data;
  Object? _erro;
  bool _carregando = true;
  int _requisicao = 0;
  int _ticks = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _carregar();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _ticks++;
      if (_ticks % widget.atualizarACadaMin == 0) {
        _carregar(silencioso: true);
      } else if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _carregar({bool silencioso = false}) async {
    final id = ++_requisicao;
    if (!silencioso) {
      setState(() {
        _carregando = true;
        _erro = null;
      });
    }
    try {
      final d = await widget.carregar();
      if (!mounted || id != _requisicao) return;
      setState(() {
        _data = d;
        _erro = null;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted || id != _requisicao) return;
      if (silencioso && _data != null) return; // mantém os dados antigos na tela
      setState(() {
        _erro = e;
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _data;
    return LayoutBuilder(builder: (context, c) {
      final pad = c.maxWidth < 700 ? 16.0 : 32.0;
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(pad, 24, pad, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.titulo, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(widget.subtitulo,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  ),
                ]),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 18,
                    child: (d == null || widget.indicadorDireita == null) ? null : widget.indicadorDireita!(d),
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                SizedBox(
                  height: 2,
                  child: _carregando ? const LinearProgressIndicator(minHeight: 2) : null,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(pad, 22, pad, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (d == null || _erro != null)
                    SizedBox(height: 300, child: _estado())
                  else
                    widget.corpo(d),
                  const SizedBox(height: 28),
                  const Text(
                    kRodape,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _estado() {
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
    return const Center(child: CircularProgressIndicator());
  }
}
