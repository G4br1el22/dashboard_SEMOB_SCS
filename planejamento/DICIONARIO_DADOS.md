# Dicionario da consulta

Fonte: view dados_consulta. Filtrar registro_diario=true e fonte_preferencial=true. Projetar somente campos permitidos; nao solicitar original ou Motorista.

| Campo | Tipo e uso |
| --- | --- |
| data | string YYYY-MM-DD; data operacional |
| tipo | familia do relatorio |
| valores.Linha | identificador preservado como string |
| valores.kmTotal | Decimal128; quilometragem |
| valores.nrViagensRealiz | inteiro; viagens em operacao_diaria |
| valores.nrViagens | inteiro; viagens em operacao_linha_diaria |
| valores.nrVeiculos | inteiro; maximo diario observado |
| valores.Catraca e Antecipados | inteiros; componentes de pagantes |
| valores.Nao Pagantes | nome real no codigo: Não Pagantes; contagem |
| valores.Total Vendas | Decimal128; vendas de creditos |

operacao_diaria prevalece sobre operacao_linha_diaria por dia e metrica. Nao somar totais municipais com as tabelas por linha. Decimal128 vira Decimal no backend e string exata no JSON; Dart converte apenas para visualizacao. XLSX segue limites numericos do Excel. Ausencia nao significa zero. Cada ambiente deve validar esquema, granularidade e conciliacao com consultas independentes.
