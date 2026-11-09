import 'package:flutter/material.dart';
import '../models/linhas_data.dart';
import '../repositories/linhas_repository.dart';
import '../widgets/tabela_linhas.dart';
import '../widgets/tela_com_filtros.dart';

class LinhasScreen extends StatelessWidget {
  final LinhasRepository? repository;
  const LinhasScreen({super.key, this.repository});
  @override
  Widget build(BuildContext context) {
    final repo = repository ?? criarLinhasRepository();
    return TelaComFiltros<LinhasData>(
        titulo: 'Linhas',
        carregar: repo.carregar,
        intervalo: (d) => (d.dataInicio, d.dataFim),
        info: (d) => d.info,
        corpoRolavel: (d, largo) =>
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${d.total} linhas no período',
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              TabelaLinhas(linhas: d.linhas, diario: false),
            ]));
  }
}
