import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../models/linhas_data.dart';
import 'api_helpers.dart';
import 'linhas_repository.dart';

/// GET /api/linhas — formato do JSON em API_CONTRATO.md
class ApiLinhasRepository implements LinhasRepository {
  final Dio _dio;
  ApiLinhasRepository({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  @override
  Future<LinhasData> carregar() async {
    final json = await apiGetJson(_dio, '/api/linhas', {});
    return LinhasData.fromJson(json);
  }
}
