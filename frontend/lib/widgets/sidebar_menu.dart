import 'package:flutter/material.dart';
import '../core/theme.dart';

class MenuItemData {
  final String label;
  final IconData icon;
  const MenuItemData(this.label, this.icon);
}

const menuItens = <MenuItemData>[
  MenuItemData('Visão geral', Icons.grid_view_rounded),
  MenuItemData('Frota e viagens', Icons.directions_bus_outlined),
  MenuItemData('Passageiros', Icons.people_outline),
  MenuItemData('Financeiro', Icons.account_balance_wallet_outlined),
  MenuItemData('Linhas', Icons.alt_route),
  MenuItemData('Relatórios', Icons.description_outlined),
  MenuItemData('Versão mobile', Icons.smartphone_outlined),
];

class SidebarMenu extends StatelessWidget {
  final int selecionado;
  final ValueChanged<int> onSelecionar;

  /// true = só ícones (janelas pequenas)
  final bool compacto;

  const SidebarMenu({
    super.key,
    required this.selecionado,
    required this.onSelecionar,
    this.compacto = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: compacto ? 72 : 254,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0E2145), Color(0xFF0C1A33)],
        ),
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          _Logo(compacto: compacto),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: menuItens.length,
              itemBuilder: (_, i) => _Item(
                data: menuItens[i],
                ativo: i == selecionado,
                compacto: compacto,
                onTap: () => onSelecionar(i),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            child: _Item(
              data: const MenuItemData('Configurações', Icons.settings_outlined),
              ativo: false,
              compacto: compacto,
            ),
          ),
          _UserCard(compacto: compacto),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  final bool compacto;
  const _Logo({required this.compacto});

  @override
  Widget build(BuildContext context) {
    final icone = Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(10)),
      child: const Icon(Icons.person_pin_circle_outlined, color: Colors.white),
    );
    if (compacto) {
      return Padding(padding: const EdgeInsets.fromLTRB(0, 18, 0, 10), child: Center(child: icone));
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      child: Row(
        children: [
          icone,
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SEMOB-SCS',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                Text('Mobilidade Urbana',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final MenuItemData data;
  final bool ativo;
  final bool compacto;
  final VoidCallback? onTap;
  const _Item({required this.data, required this.ativo, required this.compacto, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cor = ativo ? Colors.white : AppColors.textMuted;
    final conteudo = Padding(
      padding: EdgeInsets.symmetric(horizontal: compacto ? 0 : 14, vertical: 12),
      child: compacto
          ? Center(child: Icon(data.icon, size: 20, color: cor))
          : Row(
              children: [
                Icon(data.icon, size: 20, color: cor),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    data.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ativo ? Colors.white : const Color(0xFFC4CFE0),
                    ),
                  ),
                ),
              ],
            ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Tooltip(
        message: compacto ? data.label : '',
        child: Material(
          color: ativo ? const Color(0xFF1A3258) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(borderRadius: BorderRadius.circular(8), onTap: onTap, child: conteudo),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final bool compacto;
  const _UserCard({required this.compacto});

  @override
  Widget build(BuildContext context) {
    const avatar = CircleAvatar(
      radius: 16,
      backgroundColor: AppColors.accent,
      child: Text('RM', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
    );
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFF12294D), borderRadius: BorderRadius.circular(8)),
      child: compacto
          ? const Center(child: avatar)
          : const Row(
              children: [
                avatar,
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rudolf M.',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      Text('Gestor de operação',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
