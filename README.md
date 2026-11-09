# Dashboard SEMOB SCS

Flutter web e FastAPI para indicadores de transporte. Inclui filtros de data/linha, tratamento de dados ausentes e exportacao PDF/XLSX. Implementacao preparada com assistencia de IA na sessao de Guilherme; os integrantes revisam e publicam os modulos atribuidos pelo plano. Isso nao implica autoria exclusiva nem homologa regras com SEMOB/professor.

## Executar

Para iniciar tudo no Windows, abra **RODAR_SEMOB.bat**. Ele prepara dependencias, valida o projeto e abre a aplicacao. Consulte BRANCH_TEMPORARIA.md para opcoes e para remover esta branch depois do uso.

Requisitos: Windows, Python 3.13 e Git. Execute Instalar SEMOB.cmd para instalar dependencias, analisar, testar e gerar o build. Flutter validado: 3.47.9 / Dart 3.13.7. O manifesto esta em frontend/.

Depois abra Demonstracao SEMOB.cmd: http://127.0.0.1:8766. A base e sintetica e identificada; os relatorios sao arquivos reais locais.

Para banco proprio, abra Configurar MongoDB.cmd e informe seu usuario, senha, hostname do cluster e banco. Nada disso e distribuido neste repositorio. Use usuario com leitura de semob.dados_consulta e IP atual autorizado no Atlas. O formulario salva backend/.env ignorado somente apos validar a leitura. Iniciar SEMOB.cmd abre http://127.0.0.1:8765. Parar SEMOB.cmd encerra somente os processos do projeto.

## Regras e limites

A API so le dados_consulta, projetando campos operacionais permitidos e exigindo registro_diario e fonte_preferencial. Quilometragem/viagens selecionam uma familia por dia, sem somar granularidades sobrepostas. Viagens usam nrViagensRealiz no resumo e nrViagens por linha. Passageiros pagantes usam Catraca + Antecipados; nao pagantes usam o campo homonimo. Vendas de creditos nao equivalem a receita tarifaria.

Ausencias usam null, totais parciais informam cobertura e percentuais incompletos sao omitidos. Sem fonte homologada nao ha custo, receita tarifaria, pontualidade, ocupacao ou cadastro de frota. O escopo e local, sem login de equipe, e-mail automatico, coleta automatica Smart Data ou publicacao publica.

PDF e XLSX usam os mesmos filtros/calculos da consulta e ficam em backend/local/reports, separados por fonte. Credenciais, dados reais, logs, relatorios e builds nao sao versionados. O importador manual existente tem modo --apply que escreve no Atlas e nao e executado pela aplicacao.

## Verificacao

```powershell
.venv/Scripts/python.exe -m pytest -q
.venv/Scripts/python.exe -m unittest discover -s backend/tools -p test_import_semob.py
cd frontend
flutter analyze
flutter test
```

O pacote integrado foi verificado localmente: 29 testes backend/configuracao, 5 importador e 5 Flutter, analise e build. Testes automatizados usam fixtures sinteticas. Evidencias privadas do Atlas nao sao distribuidas; cada ambiente real precisa ser validado pelo seu responsavel.

Contrato em API_CONTRATO.md. Documentacao em planejamento/. As branches individuais possuem dependencias e a validacao completa e realizada apos integracao das cinco partes.
