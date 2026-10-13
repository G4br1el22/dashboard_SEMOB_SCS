import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../models/filtros.dart';
import '../models/financeiro_data.dart';
import 'api_helpers.dart';
import 'financeiro_repository.dart';

/// GET /api/financeiro — formato do JSON em API_CONTRATO.md
class ApiFinanceiroRepository implements FinanceiroRepository {
  final Dio _dio;
  ApiFinanceiroRepository({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  @override
  Future<FinanceiroData> carregar(FiltrosDashboard filtros) async {
    final json = await apiGetJson(_dio, '/api/financeiro', filtros.toQuery());
    return FinanceiroData.fromJson(json);
  }
}
