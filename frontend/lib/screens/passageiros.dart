import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/chart_data.dart';
import '../models/filtros.dart';
import '../repositories/passageiros_repository.dart';
import '../widgets/bar_chart_demanda.dart';
import '../widgets/donut_chart_comp.dart';
import '../widgets/kpi_card.dart';
import '../widgets/top_header.dart';

class PassageirosScreen extends StatefulWidget {
  /// Troque por ApiPassageirosRepository quando o back estiver pronto.
  final PassageirosRepository repository;
  PassageirosScreen({super.key, PassageirosRepository? repository})
      : repository = repository ?? MockPassageirosRepository();

  @override
  State<PassageirosScreen> createState() => _PassageirosScreenState();
}

class _PassageirosScreenState extends State<PassageirosScreen> {
  Periodo _periodo = Periodo.dia;
  bool _diasUteis = true;
  late Future<PassageirosData> _future = _carregar();

  static const _rodape =
      'SEMOB · Secretaria de Mobilidade Urbana de São Caetano do Sul · Instituto Mauá de Tecnologia · TTI206 · 2026-2';

  Future<PassageirosData> _carregar() => widget.repository.carregar(
        periodo: _periodo,
        compararAnoAnterior: true,
        apenasDiasUteis: _diasUteis,
      );

  void _recarregar() => setState(() => _future = _carregar());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PassageirosData>(
      future: _future,
      builder: (context, snap) {
        final data = snap.data;

        final header = TopHeader(
          titulo: 'Passageiros',
          dataReferencia: data?.dataReferencia ?? DateTime.now().subtract(const Duration(days: 1)),
          periodo: _periodo,
          onPeriodo: (p) {
            _periodo = p;
            _recarregar();
          },
          apenasDiasUteis: _diasUteis,
          onDiasUteis: (v) {
            _diasUteis = v;
            _recarregar();
          },
        );

        return LayoutBuilder(builder: (context, c) {
          final pad = c.maxWidth < 700 ? 16.0 : 32.0;
          final largo = c.maxWidth - pad * 2 >= 900 && c.maxHeight >= 640;

          return Padding(
            padding: EdgeInsets.fromLTRB(pad, 24, pad, 16),
            child: largo ? _layoutLargo(header, snap, data) : _layoutEmpilhado(header, snap, data),
          );
        });
      },
    );
  }

  // Janela grande: tudo cabe na tela, gráficos lado a lado.
  Widget _layoutLargo(Widget header, AsyncSnapshot<PassageirosData> snap, PassageirosData? data) {
    return Column(
      children: [
        header,
        const SizedBox(height: 24),
        Expanded(child: _estado(snap, data, (d) => _corpoLargo(d))),
        const SizedBox(height: 12),
        const Text(_rodape, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }

  // Janela pequena: tudo empilhado e com rolagem.
  Widget _layoutEmpilhado(Widget header, AsyncSnapshot<PassageirosData> snap, PassageirosData? data) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 24),
          if (data == null || snap.hasError)
            SizedBox(height: 200, child: _estado(snap, data, (_) => const SizedBox()))
          else
            _corpoEmpilhado(data),
          const SizedBox(height: 16),
          const Text(_rodape, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _estado(AsyncSnapshot<PassageirosData> snap, PassageirosData? data,
      Widget Function(PassageirosData) builder) {
    if (snap.hasError) return Center(child: Text('Erro ao carregar dados: ${snap.error}'));
    if (data == null) return const Center(child: CircularProgressIndicator());
    return builder(data);
  }

  Widget _kpis(PassageirosData d) => LayoutBuilder(builder: (context, c) {
        final cards = [
          KpiCard(kpi: d.pagantes, icone: Icons.people_outline),
          KpiCard(kpi: d.naoPagantes, icone: Icons.person_off_outlined),
        ];
        if (c.maxWidth < 480) {
          return Column(children: [cards[0], const SizedBox(height: 12), cards[1]]);
        }
        return Row(children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 16),
          Expanded(child: cards[1]),
        ]);
      });

  Widget _corpoLargo(PassageirosData d) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(flex: 2, child: _kpis(d)),
            const SizedBox(width: 22),
            const Expanded(child: SizedBox()),
          ],
        ),
        const SizedBox(height: 22),
        Expanded(
          child: Row(
            children: [
              Expanded(flex: 2, child: BarChartDemanda(faixas: d.faixas)),
              const SizedBox(width: 22),
              Expanded(
                child: DonutChartComp(pagantes: d.pagantes.valor, naoPagantes: d.naoPagantes.valor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _corpoEmpilhado(PassageirosData d) {
    return Column(
      children: [
        _kpis(d),
        const SizedBox(height: 16),
        SizedBox(height: 400, child: BarChartDemanda(faixas: d.faixas)),
        const SizedBox(height: 16),
        SizedBox(
          height: 420,
          child: DonutChartComp(pagantes: d.pagantes.valor, naoPagantes: d.naoPagantes.valor),
        ),
      ],
    );
  }
}
