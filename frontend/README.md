# Interface SEMOB SCS

Executar comandos Flutter nesta pasta. SDK validado Flutter 3.47.9 / Dart 3.13.7. O padrão usa a API na mesma origem; o servidor FastAPI da raiz entrega build/web. Não abrir index.html com file://.

```powershell
flutter pub get --enforce-lockfile
flutter analyze
flutter test
flutter build web --release --no-web-resources-cdn --dart-define=USE_MOCK=false
```

Para desenvolvimento separado:

```powershell
flutter run -d chrome --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=http://127.0.0.1:8766
```

A porta 8766 é a API de demonstração sintética; 8765 é a real. USE_MOCK=true mantém mocks antigos do cliente para desenvolvimento, identificados pela faixa de demonstração. Para exportação completa, usar API demo explícita. Regras e limitações estão no README da raiz e em planejamento/EXECUCAO_FRONTEND.md.
