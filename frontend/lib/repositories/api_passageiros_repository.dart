import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../models/chart_data.dart';
import '../models/filtros.dart';
import 'api_helpers.dart';
import 'passageiros_repository.dart';

/// Chama o back (FastAPI). Endpoint e formato do JSON: API_CONTRATO.md
class ApiPassageirosRepository implements PassageirosRepository {
  final Dio _dio;
  ApiPassageirosRepository({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  @override
  Future<PassageirosData> carregar(FiltrosDashboard filtros) async {
    final json = await apiGetJson(_dio, '/api/passageiros', filtros.toQuery());
    return PassageirosData.fromJson(json);
  }
}
