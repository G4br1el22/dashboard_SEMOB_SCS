# Executar frontend

SDK validado: Flutter 3.47.9, Dart 3.13.7. Comandos dentro de frontend/: flutter pub get --enforce-lockfile; flutter analyze; flutter test; flutter build web --release --no-web-resources-cdn --dart-define=USE_MOCK=false.

Sem API_BASE_URL, o cliente usa a origem do servidor que entrega build/web. Para desenvolvimento separado, flutter run -d chrome --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=http://127.0.0.1:8766. Nao abrir index.html com file://. USE_MOCK=true mantem mocks do cliente identificados; a API demo permite testar exportacoes reais sem banco.

O alvo validado e web. Instalador usa Flutter do PATH ou instala tag fixada em .tools/flutter, ignorado pelo Git. Nenhum caminho pessoal de SDK e distribuido.
