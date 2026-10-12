/// Configuração em tempo de execução, via --dart-define:
///   flutter run -d chrome                                   -> usa dados fictícios (mock)
///   flutter run -d chrome --dart-define=USE_MOCK=false      -> usa a API real
///   flutter run -d chrome --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=http://localhost:8000
class AppConfig {
  static const bool usarMock = bool.fromEnvironment('USE_MOCK', defaultValue: true);
  static const String apiBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000');
}
