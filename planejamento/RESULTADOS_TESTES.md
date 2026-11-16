# Resultados e reproducao

Na preparacao integrada passaram 29 testes backend/configuracao, 5 testes do importador e 5 Flutter. Analise e build web passaram. Jornada em navegador verificou telas, filtros, consulta vazia, erro/nova tentativa e geracao/download PDF/XLSX. As fixtures automaticas sao sinteticas e identificadas.

Evidencias operacionais privadas nao acompanham estes commits. Cada integrante revisa seu diff; a verificacao executavel completa acontece na integracao, pois os modulos dependem uns dos outros. O coordenador deve executar instalar.ps1, conferir source=demo e bloquear merge diante de falha.

Comandos: .venv/Scripts/python.exe -m pytest -q; .venv/Scripts/python.exe -m unittest discover -s backend/tools -p test_import_semob.py; em frontend, flutter analyze e flutter test. O script de integracao executa instalacao, analise, testes e build antes de publicar a branch candidata.
