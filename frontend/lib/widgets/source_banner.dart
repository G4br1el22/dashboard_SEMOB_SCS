import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/config.dart';
import '../core/theme.dart';

class SourceBanner extends StatefulWidget {
  const SourceBanner({super.key});
  @override
  State<SourceBanner> createState() => _SourceBannerState();
}

class _SourceBannerState extends State<SourceBanner> {
  String message = AppConfig.usarMock
      ? 'DEMONSTRAÇÃO — dados fictícios no navegador'
      : 'Verificando fonte dos dados…';
  @override
  void initState() {
    super.initState();
    if (!AppConfig.usarMock) _load();
  }

  Future<void> _load() async {
    try {
      final r = await ApiClient.dio.get('/api/status');
      if (!mounted) return;
      setState(() {
        message =
            '${r.data['mensagem']} · última data disponível: ${r.data['ultima_data_disponivel']}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        message =
            'MongoDB ainda não conectado. Use Configurar MongoDB.cmd e reinicie a aplicação.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: const Color(0xFF122B36),
        child: Row(children: [
          Expanded(
              child: Text(message,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textPrimary))),
          if (!AppConfig.usarMock)
            IconButton(
                onPressed: _load,
                tooltip: 'Verificar conexão',
                icon: const Icon(Icons.refresh, size: 16))
        ]),
      );
}
