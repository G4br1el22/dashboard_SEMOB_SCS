# Contrato da API SEMOB versão local 1

A mesma API serve Flutter e relatórios. Base local real http://127.0.0.1:8765; demonstração explícita http://127.0.0.1:8766. OpenAPI interativo em /docs. O cliente não recebe URI MongoDB.

## Rotas

| Método e caminho | Resposta |
| --- | --- |
| GET /api/health | Processo disponível, fonte e presença de configuração. Não comprova acesso ao banco. |
| GET /api/status | Fonte e última data operacional disponível; 503 se consulta indisponível. |
| GET /api/visao-geral | Indicadores, séries, linhas, cobertura, avisos e diário. |
| GET /api/passageiros | Mesmo objeto de consulta, consumido pelo painel de passageiros. |
| GET /api/frota-viagens | Mesmo objeto, incluindo resumo de frota com campos anuláveis. |
| GET /api/financeiro | Mesmo objeto, incluindo vendas_creditos separadas de receita. |
| GET /api/linhas | Mesmo objeto, incluindo linhas e mesmos filtros temporais. |
| GET /api/relatorios | tipos, recentes, fonte, data_inicio e data_fim. |
| POST /api/relatorios/gerar | 201 e metadados do arquivo persistido. |
| GET /api/relatorios/{id}/download | PDF/XLSX com Content-Disposition attachment; 404 se inexistente. |

## Filtros

Os GETs analíticos e a listagem de relatórios aceitam: periodo=dia|semana|quinzena|mes|datas; comparacao=nenhuma|periodo_anterior|ano_anterior; dias_uteis=true|false; linha opcional de até 80 caracteres. Padrões: dia, nenhuma, false e todas as linhas. Parâmetros desconhecidos são rejeitados.

Quando periodo=datas, data_inicio e data_fim são obrigatórias, no formato YYYY-MM-DD, com limites inclusivos e até 366 dias. Para outros períodos, não enviar essas duas datas. Dia/semana/quinzena/mês representam janelas de 1/7/15/30 dias até a última data disponível, sem associação artificial à data atual. Segunda a sexta não exclui feriados.

Comparação anterior usa janela contígua de igual duração; ano anterior troca o ano e ajusta 29/02 para 28/02. Percentual só existe com cobertura completa em ambas as janelas e base diferente de zero. O relatório recebe os mesmos filtros no corpo JSON, além de tipo=operacional_pdf|operacional_xlsx.

## Dados analíticos

Campos de metadados: data_inicio, data_fim e ultima_data_disponivel são datas ISO; granularidade é dia; fonte é mongo ou demo; consultado_em é timestamp UTC; sincronizado_em é null porque não há medição de ingestão automática; sem_dados é booleano e avisos é lista de textos.

Indicadores quilometragem, viagens, pagantes, nao_pagantes, vendas_creditos, receita e custo têm esta estrutura:

```json
{"valor":"1296.75","variacao":null,"sparkline":["1296.75"],"parcial":false,"dias_observados":1,"dias_esperados":1}
```

Decimais são strings JSON exatas ou null. O Dart aceita essas strings e números para visualização. Zero observado continua sendo "0"; ausência usa null. Totais parciais somam apenas dias observados e informam cobertura, sem sparkline ou comparação enganosa. Receita e custo permanecem null até haver fonte e regra de negócio homologadas; Total Vendas não é receita tarifária.

serie contém data, rotulo dd/MM, pagantes, nao_pagantes e viagens. Datas faltantes permanecem na série com null, interrompendo os traçados. financeiro é lista vazia nesta versão, sem série inventada. diario contém uma linha por dia elegível e os valores de cada métrica, usado nas exportações.

linhas contém codigo, nome, km, viagens, pagantes, nao_pagantes, ocupacao, pontualidade e status. Campos numéricos podem ser null. codigo é string e nome é "Linha <codigo>" sem inventar itinerário. Sem fonte homologada, ocupacao e pontualidade são null e status é indisponivel. O filtro de linha exclui totais municipais sem Linha.

frota contém total, em_operacao, em_manutencao, idade_media e meta_idade. Apenas em_operacao é derivável do máximo diário de nrVeiculos; os demais campos ficam null. Não representa veículos únicos no período.

## Relatórios

A listagem retorna apenas formatos implementados, PDF e XLSX. O POST retorna id hexadecimal de 32 caracteres, titulo, formato, gerado_em UTC, fonte, data_inicio, data_fim e filtros. O conteúdo usa o mesmo serviço e filtro do dashboard; gerar não envia e-mail. Arquivos e metadados ficam locais em backend/local/reports/{fonte}, persistem entre reinícios e não são gravados no Atlas.

```json
{"tipo":"operacional_xlsx","periodo":"datas","comparacao":"nenhuma","dias_uteis":false,"data_inicio":"2026-09-01","data_fim":"2026-09-03","linha":"101"}
```

## Erros e limites

422: filtros inválidos, intervalo acima de 366 dias, tipo de relatório inválido ou exportação de período sem dados. 503: Mongo não configurado, inacessível ou consulta extensa. 404: relatório não encontrado. O JSON de erro contém detail com mensagem pública, sem URI, senha ou documentos originais.

Consultas leem no máximo 200.000 registros, com timeout de 25 segundos e cache de até 15 segundos. A projeção permite somente campos operacionais conhecidos. Não existe parâmetro para consulta MongoDB arbitrária. A aplicação deve permanecer em loopback: não há autenticação para publicação pública.


## Esquema real confirmado

Verificado em 08/11/2026: viagens do resumo usam nrViagensRealiz; viagens de operacao_linha_diaria usam nrViagens. A projeção permite ambos e a agregação seleciona o campo conforme a família, sem duplicar valores. A instância contém dados até [data privada omitida].
