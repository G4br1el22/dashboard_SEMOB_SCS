# Rastreabilidade

| Requisito | Caso | Código | Evidência |
| --- | --- | --- | --- |
| RF01–RF06 | Ingestão prévia | backend/tools/import_semob.py | Cinco testes unittest originais |
| RF07 | UC01 | repositories/data.py | test_mongo_query_projection_and_no_writes |
| RF08–RF09 | UC01 | services/dashboard.py; main.py; screens/ | test_contract_routes; parsing Flutter; navegação web |
| RF10 | UC01 e UC02 | schemas.py; dashboard.py; filtros.dart | test_invalid_filters; test_weekdays_and_line_filter; comparação completa/parcial |
| RF11 | UC03 | services/reports.py; relatorios.dart | XLSX conciliado, PDF válido, persistência e download inexistente |
| RF12 | UC01 | tela_com_filtros.dart; source_banner.dart | Teste Flutter erro/nova tentativa e mensagens no navegador |
| RF13 | UC01 | DemoRepository; Settings | test_mongo_unconfigured_is_503_not_demo; banner sintético |
| RNF06 e RNF12 | UC01 | decimal_value; kpi | test_decimal128_precision_and_missing_field; test_partial_interval_and_no_fabricated_comparison |
| RNF09 | UC01 e UC03 | Layout Flutter | Teste 390 px e revisão em navegador |
| Integração Atlas | UC04 | verificar_banco.py | Aprovado tecnicamente: leitura real, esquema, cobertura e conciliação em evidencias/real/ |
