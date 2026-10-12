import 'package:dio/dio.dart';
import 'config.dart';

/// Cliente HTTP único do app (Dio). Se precisar de autenticação,
/// adicione um interceptor aqui.
class ApiClient {
  ApiClient._();

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
    ),
  );
}
