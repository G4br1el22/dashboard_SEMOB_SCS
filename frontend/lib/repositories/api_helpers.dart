import 'package:dio/dio.dart';

import 'passageiros_repository.dart' show RepositorioException;

/// GET que devolve JSON (objeto) e traduz erros de rede em mensagens amigáveis.
Future<Map<String, dynamic>> apiGetJson(Dio dio, String path, Map<String, dynamic> query) async {
  try {
    final res = await dio.get(path, queryParameters: query);
    return res.data as Map<String, dynamic>;
  } on DioException catch (e) {
    throw RepositorioException(
      e.response != null
          ? 'O servidor respondeu com erro (${e.response!.statusCode}).'
          : 'Não foi possível conectar ao servidor.',
    );
  } catch (_) {
    throw RepositorioException('Resposta inesperada do servidor.');
  }
}

/// POST com corpo JSON que devolve JSON (objeto).
Future<Map<String, dynamic>> apiPostJson(Dio dio, String path, Map<String, dynamic> body) async {
  try {
    final res = await dio.post(path, data: body);
    return res.data as Map<String, dynamic>;
  } on DioException catch (e) {
    throw RepositorioException(
      e.response != null
          ? 'O servidor respondeu com erro (${e.response!.statusCode}).'
          : 'Não foi possível conectar ao servidor.',
    );
  } catch (_) {
    throw RepositorioException('Resposta inesperada do servidor.');
  }
}
