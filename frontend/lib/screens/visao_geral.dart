import 'package:flutter/material.dart';
// Importações baseadas na estrutura de pastas definida anteriormente
// import '../widgets/kpi_card.dart';
// import '../widgets/bar_chart_demanda.dart';
// import '../widgets/donut_chart_comp.dart';

class VisaoGeralScreen extends StatefulWidget {
  const VisaoGeralScreen({Key? key}) : super(key: key);

  @override
  State<VisaoGeralScreen> createState() => _VisaoGeralScreenState();
}

class _VisaoGeralScreenState extends State<VisaoGeralScreen> {
  // Estado para controlar o filtro de tempo selecionado
  String filtroSelecionado = 'Diária';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Fundo escuro do mockup
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildFiltrosTempo(),
            const SizedBox(height: 24),
            _buildKpiGrid(),
            const SizedBox(height: 24),
            _buildGraficos(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard de Operação de Transporte',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Terça, 17 de fevereiro de 2026', // Idealmente alimentado via DateTime.now()
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildActionButton(Icons.search, 'Buscar Info...'),
            const SizedBox(width: 12),
            _buildActionButton(Icons.refresh, 'Atualizar'),
            const SizedBox(width: 12),
            _buildActionButton(Icons.download, 'Exportar', isPrimary: true),
          ],
        )
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isPrimary ? Colors.white : const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: isPrimary ? null : Border.all(color: Colors.grey[800]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isPrimary ? Colors.black : Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isPrimary ? Colors.black : Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltrosTempo() {
    return Row(
      children: ['Diária', 'Semanal', 'Mensal'].map((filtro) {
        bool isSelected = filtroSelecionado == filtro;
        return GestureDetector(
          onTap: () {
            setState(() {
              filtroSelecionado = filtro;
              // Aqui você chamará o Provider/Bloc para buscar os novos dados na API Python
            });
          },
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.white : Colors.grey[600]!,
              ),
            ),
            child: Text(
              filtro,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.grey[300],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKpiGrid() {
    // Grid contendo os 6 cartões superiores. 
    // Na prática, você substituirá os Containers vazios pelo widget KpiCard real.
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      childAspectRatio: 2.5, // Ajuste para a proporção retangular dos cards
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _mockKpiCard('Quilometragem', '18.420 km', Icons.directions_bus),
        _mockKpiCard('Viagens realizadas', '1.284', Icons.route),
        _mockKpiCard('Passageiros pagantes', '42.380', Icons.person),
        _mockKpiCard('Passageiros não pagantes', '15.910', Icons.person_off),
        _mockKpiCard('Receita tarifária', 'R\$ 187.540', Icons.attach_money),
        _mockKpiCard('Custo operacional', 'R\$ 214.300', Icons.money_off),
      ],
    );
  }

  Widget _buildGraficos() {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            // Substituir por: const BarChartDemandaWidget()
            child: _mockChartContainer('Demanda de passageiros (Gráfico de Barras)'),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            // Substituir por: const DonutChartCompWidget()
            child: _mockChartContainer('Composição de demanda (Gráfico de Rosca)'),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS TEMPORÁRIOS DE MOCKUP ---
  // Estes métodos simulam o visual dos componentes que estarão na pasta /widgets

  Widget _mockKpiCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey[400], size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: Colors.grey[400])),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mockChartContainer(String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}