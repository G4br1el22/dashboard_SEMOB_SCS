import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../models/filtros.dart';
import '../models/frota_viagens_data.dart';
import 'api_helpers.dart';
import 'frota_viagens_repository.dart';

/// GET /api/frota-viagens — formato do JSON em API_CONTRATO.md
class ApiFrotaViagensRepository implements FrotaViagensRepository {
  final Dio _dio;
  ApiFrotaViagensRepository({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  @override
  Future<FrotaViagensData> carregar(FiltrosDashboard filtros) async {
    final json = await apiGetJson(_dio, '/api/frota-viagens', filtros.toQuery());
    return FrotaViagensData.fromJson(json);
  }
}
