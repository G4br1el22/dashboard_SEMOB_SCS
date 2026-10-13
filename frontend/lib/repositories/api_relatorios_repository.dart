import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/config.dart';
import '../models/relatorios_data.dart';
import 'api_helpers.dart';
import 'relatorios_repository.dart';

/// GET  /api/relatorios                 -> tipos + recentes
/// POST /api/relatorios/gerar           -> gera e devolve o documento
/// GET  /api/relatorios/{id}/download   -> arquivo (aberto pelo navegador)
/// Formato dos JSONs em API_CONTRATO.md
class ApiRelatoriosRepository implements RelatoriosRepository {
  final Dio _dio;
  ApiRelatoriosRepository({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  @override
  Future<RelatoriosData> carregar() async {
    final json = await apiGetJson(_dio, '/api/relatorios', {});
    return RelatoriosData.fromJson(json);
  }

  @override
  Future<RelatorioGerado> gerar(String tipoId) async {
    final json = await apiPostJson(_dio, '/api/relatorios/gerar', {'tipo': tipoId});
    return RelatorioGerado.fromJson(json);
  }

  @override
  Uri? urlDownload(RelatorioGerado r) =>
      Uri.parse('${AppConfig.apiBaseUrl}/api/relatorios/${r.id}/download');
}
