class AppConfig {
  static const bool usarMock =
      bool.fromEnvironment('USE_MOCK', defaultValue: false);
  static const String apiBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');
}
