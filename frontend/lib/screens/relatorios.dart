import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme.dart';
import '../models/relatorios_data.dart';
import '../repositories/relatorios_repository.dart';
import '../widgets/indicador_sync.dart';
import '../widgets/tela_simples.dart';

class RelatoriosScreen extends StatelessWidget {
  /// Opcional (útil em testes). Se nulo, usa mock ou API conforme AppConfig.
  final RelatoriosRepository? repository;
  const RelatoriosScreen({super.key, this.repository});

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? criarRelatoriosRepository();
    return TelaSimples<RelatoriosData>(
      titulo: 'Relatórios',
      subtitulo: 'Geração e exportação de relatórios operacionais',
      carregar: repo.carregar,
      indicadorDireita: (d) => IndicadorSync(sincronizadoEm: d.sincronizadoEm),
      corpo: (d) => _CorpoRelatorios(dados: d, repo: repo),
    );
  }
}

IconData _iconeFormato(FormatoRelatorio f) =>
    f == FormatoRelatorio.pdf ? Icons.description_outlined : Icons.table_chart_outlined;

class _CorpoRelatorios extends StatefulWidget {
  final RelatoriosData dados;
  final RelatoriosRepository repo;
  const _CorpoRelatorios({required this.dados, required this.repo});

  @override
  State<_CorpoRelatorios> createState() => _CorpoRelatoriosState();
}

class _CorpoRelatoriosState extends State<_CorpoRelatorios> {
  late List<RelatorioGerado> _recentes = List.of(widget.dados.recentes);
  final Set<String> _gerando = {};

  @override
  void didUpdateWidget(covariant _CorpoRelatorios old) {
    super.didUpdateWidget(old);
    // Chegaram dados novos do back (atualização automática): sincroniza a lista.
    if (!identical(old.dados, widget.dados)) _recentes = List.of(widget.dados.recentes);
  }

  void _aviso(String texto, {SnackBarAction? acao}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto), action: acao, behavior: SnackBarBehavior.floating));
  }

  Future<void> _gerar(RelatorioTipo t) async {
    setState(() => _gerando.add(t.id));
    try {
      final r = await widget.repo.gerar(t.id);
      if (!mounted) return;
      setState(() {
        _recentes.insert(0, r);
        if (_recentes.length > 10) _recentes.removeLast();
      });
      _aviso('"${t.titulo}" gerado com sucesso.',
          acao: SnackBarAction(label: 'Baixar', onPressed: () => _baixar(r)));
    } catch (e) {
      if (mounted) _aviso('Não foi possível gerar o relatório: $e');
    } finally {
      if (mounted) setState(() => _gerando.remove(t.id));
    }
  }

  Future<void> _baixar(RelatorioGerado r) async {
    final uri = widget.repo.urlDownload(r);
    if (uri == null) {
      _aviso('Modo de demonstração: download de "${r.titulo}" simulado.');
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) _aviso('Não foi possível abrir o download.');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(builder: (context, c) {
          const gap = 16.0;
          final cols = c.maxWidth >= 720 ? 2 : 1;
          final largura = ((c.maxWidth - gap * (cols - 1)) / cols).floorToDouble();
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final t in widget.dados.tipos)
                SizedBox(
                  width: largura,
                  child: _CartaoTipo(
                    tipo: t,
                    gerando: _gerando.contains(t.id),
                    onGerar: () => _gerar(t),
                  ),
                ),
            ],
          );
        }),
        const SizedBox(height: 22),
        _Recentes(recentes: _recentes, onBaixar: _baixar),
      ],
    );
  }
}

class _IconeBox extends StatelessWidget {
  final IconData icone;
  const _IconeBox(this.icone);

  @override
  Widget build(BuildContext context) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: const Color(0xFF16253F), borderRadius: BorderRadius.circular(10)),
        child: Icon(icone, size: 20, color: AppColors.pagantes),
      );
}

class _CartaoTipo extends StatelessWidget {
  final RelatorioTipo tipo;
  final bool gerando;
  final VoidCallback onGerar;
  const _CartaoTipo({required this.tipo, required this.gerando, required this.onGerar});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 142),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconeBox(_iconeFormato(tipo.formato)),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 9),
                  child: Text(tipo.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFF1A2A45), borderRadius: BorderRadius.circular(20)),
                child: Text(tipo.formato.rotulo,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(tipo.descricao, style: const TextStyle(fontSize: 13.5, color: Color(0xFFC4CFE0))),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.schedule, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(tipo.frequencia,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ),
              FilledButton.icon(
                onPressed: gerando ? null : onGerar,
                icon: gerando
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.file_download_outlined, size: 16),
                label: Text(gerando ? 'Gerando…' : 'Gerar'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  disabledBackgroundColor: AppColors.accent.withOpacity(0.6),
                  disabledForegroundColor: Colors.white,
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Recentes extends StatelessWidget {
  final List<RelatorioGerado> recentes;
  final ValueChanged<RelatorioGerado> onBaixar;
  const _Recentes({required this.recentes, required this.onBaixar});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat("dd/MM/yyyy · HH'h'mm", 'pt_BR');
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Relatórios recentes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Documentos gerados e enviados automaticamente por e-mail',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          const SizedBox(height: 16),
          if (recentes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('Nenhum relatório gerado ainda.', style: TextStyle(color: AppColors.textMuted)),
              ),
            )
          else
            for (final r in recentes)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    _IconeBox(_iconeFormato(r.formato)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.titulo,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Row(children: [
                            const Icon(Icons.mail_outline, size: 13, color: AppColors.textMuted),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(fmt.format(r.geradoEm),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            ),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => onBaixar(r),
                      icon: const Icon(Icons.file_download_outlined, size: 16),
                      label: const Text('Baixar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border),
                        minimumSize: const Size(0, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
