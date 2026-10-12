import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../widgets/sidebar_menu.dart';
import 'passageiros.dart';
import 'visao_geral.dart';

class LayoutBase extends StatefulWidget {
  const LayoutBase({super.key});

  @override
  State<LayoutBase> createState() => _LayoutBaseState();
}

class _LayoutBaseState extends State<LayoutBase> {
  int _indice = 0; // Visão geral

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, c) {
          final compacto = c.maxWidth < 1000;
          return Row(
            children: [
              SidebarMenu(
                selecionado: _indice,
                compacto: compacto,
                onSelecionar: (i) => setState(() => _indice = i),
              ),
              Expanded(child: _tela()),
            ],
          );
        },
      ),
    );
  }

  Widget _tela() {
    switch (_indice) {
      case 0:
        return const VisaoGeralScreen();
      case 2:
        return const PassageirosScreen();
      default:
        return Center(
          child: Text(
            '${menuItens[_indice].label} — em construção',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 16),
          ),
        );
    }
  }
}
