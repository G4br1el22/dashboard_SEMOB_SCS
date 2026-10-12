import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../models/filtros.dart';
import '../models/visao_geral_data.dart';
import 'api_helpers.dart';
import 'visao_geral_repository.dart';

/// GET /api/visao-geral — formato do JSON em API_CONTRATO.md
class ApiVisaoGeralRepository implements VisaoGeralRepository {
  final Dio _dio;
  ApiVisaoGeralRepository({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  @override
  Future<VisaoGeralData> carregar(FiltrosDashboard filtros) async {
    final json = await apiGetJson(_dio, '/api/visao-geral', filtros.toQuery());
    return VisaoGeralData.fromJson(json);
  }
}
