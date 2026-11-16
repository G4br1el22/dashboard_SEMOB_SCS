# Executar backend

Python 3.13. Na raiz: instalar dependencias com .venv/Scripts/python.exe -m pip install -r backend/requirements-lock.txt. Instalar SEMOB.cmd prepara ambiente e build.

Demo: SEMOB_SOURCE=demo, uvicorn backend.main:app --host 127.0.0.1 --port 8766. Real: SEMOB_SOURCE=mongo, mesma entrada na porta 8765, apos configurar seu proprio backend/.env. Os atalhos fazem a inicializacao. /api/health verifica processo; /api/status verifica dados; /docs oferece OpenAPI. Relatorios persistem localmente. Sem Mongo configurado, retornar 503 sem fallback de dados.

Nao copiar credenciais de colegas. Mantenha o servidor vinculado a loopback. Configurar MongoDB.cmd recebe usuario/senha de banco em campos locais, testa leitura e salva configuracao ignorada. Nenhuma escrita no Atlas e feita pelo dashboard.
