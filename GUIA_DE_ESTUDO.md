# Guia de estudo do código — Dashboard SEMOB-SCS

Este guia existe para que os cinco integrantes consigam **explicar e modificar** o código na banca, não só mostrá-lo funcionando. Ele foi escrito sobre o código integrado em 16/11/2026 (as cinco branches `equipe/*` juntas); os números de linha valem para esse estado.

O método tem três níveis, e só o terceiro prova que você entendeu:

1. **Dizer** o que cada arquivo faz, com as suas palavras.
2. **Seguir** um dado de ponta a ponta, do clique na tela até o banco e de volta.
3. **Mudar** uma linha, prever qual teste vai falhar e conferir.

Plano sugerido: todos fazem a trilha comum (seção 2, cerca de 40 min), cada um faz a sua trilha (seção 3, cerca de 1h30) e o grupo fecha com a sessão da seção 5 (1 h).

## 1. O sistema em uma página

| Pasta ou arquivo | Responsabilidade | Dono no grupo |
| --- | --- | --- |
| `backend/tools/import_semob.py` | Lê os HTML da Smart Data e grava no MongoDB. Roda à parte, à mão. | Guilherme |
| `backend/config/database.py` | Carrega a configuração local e abre a conexão com TLS. | Guilherme |
| `backend/repositories/data.py` | Única porta de leitura dos dados: banco real ou base sintética. | Guilherme |
| `backend/models/schemas.py` | Define e valida os filtros aceitos pela API. | Gabriel |
| `backend/services/dashboard.py` | Todas as regras de cálculo dos indicadores. | Gabriel |
| `backend/main.py` | Rotas HTTP, tratamento de erro e entrega do site. | Gabriel |
| `backend/services/reports.py` | Gera e guarda PDF e XLSX. | Larissa |
| `backend/tests/`, `backend/tools/test_import_semob.py` | Testes automatizados. | Larissa |
| `frontend/lib/` | Aplicação Flutter Web: telas, modelos, chamadas à API. | Rebecca |
| `planejamento/` | Requisitos, casos de uso, rastreabilidade, processos. | Isabela |

O dado anda sempre no mesmo sentido: **HTML → importador → MongoDB (view `dados_consulta`) → repositório → serviço → rota → Flutter**. Nenhuma camada pula a anterior.

## 2. Trilha comum: um clique, do início ao fim

Todos devem conseguir narrar este caminho sem olhar. O exemplo é o clique em **Mês** na tela Visão geral.

1. **O clique vira um filtro novo.** Em [tela_com_filtros.dart](frontend/lib/widgets/tela_com_filtros.dart#L94), `_escolherPeriodo` chama `_aplicar` (linha 89), que troca `_filtros` e chama `_carregar` (linha 66).
2. **A tela entra em carregamento.** `_carregar` zera `_data` e `_erro` e incrementa `_requisicao` (linhas 67 a 72). Esse contador impede que uma resposta antiga sobrescreva a mais nova (linhas 75 e 81).
3. **A tela pede os dados ao repositório.** [visao_geral.dart](frontend/lib/screens/visao_geral.dart#L30) entrega `repo.carregar` para a tela. Quem decide entre API e dados fictícios é [visao_geral_repository.dart](frontend/lib/repositories/visao_geral_repository.dart#L12), a partir de `USE_MOCK` em [config.dart](frontend/lib/core/config.dart).
4. **O filtro vira texto de URL.** `toQuery` em [filtros.dart](frontend/lib/models/filtros.dart#L71) monta `periodo=mes&comparacao=nenhuma&dias_uteis=false`. A chamada sai por [api_helpers.dart](frontend/lib/repositories/api_helpers.dart#L6), que também traduz erro de rede em mensagem legível.
5. **A API recebe e valida.** Em [main.py](backend/main.py#L71), cinco rotas apontam para a mesma função `dashboard`. O FastAPI monta um objeto `Filters` ([schemas.py](backend/models/schemas.py#L20)); se algo for inválido, o tratador da linha 53 responde 422 com uma mensagem fixa.
6. **O serviço calcula o intervalo.** `build_dashboard` em [dashboard.py](backend/services/dashboard.py#L105) pergunta ao repositório a última data disponível e usa `bounds` (linha 18): "mês" significa os 30 dias corridos até essa data, não o mês do calendário.
7. **O repositório lê o banco.** `read` em [data.py](backend/repositories/data.py#L55) consulta só a view, só registros diários preferenciais (linhas 62 e 63), pedindo só os campos da lista `FIELDS` (linhas 69 e 70). Há limite de 200.000 registros, tempo máximo de 25 s e cache de 15 s.
8. **O serviço aplica as regras.** `daily_values` (linha 54) agrupa por dia e por tipo de relatório. Para cada indicador ele usa **a primeira família que tiver dado naquele dia** (linha 63) e, se faltar qualquer número, devolve `None` em vez de zero (linha 68). `kpi` (linha 75) soma os dias e informa a cobertura.
9. **A resposta volta como texto exato.** `json_response` em [main.py](backend/main.py#L20) transforma cada `Decimal` em string. No Flutter, `numeroJson` em [json_values.dart](frontend/lib/models/json_values.dart#L2) converte para número só na hora de desenhar, e `KpiModel.fromJson` ([kpi_model.dart](frontend/lib/models/kpi_model.dart#L30)) monta cada cartão.

**Teste de entendimento:** refaça a narração para o clique em "Gerar" na tela Relatórios. Dica: a rota é a da linha 85 de `main.py`, e ela chama o mesmo `build_dashboard`.

## 3. Trilhas individuais

Em cada trilha: leia os arquivos na ordem, responda às perguntas por escrito e faça os experimentos da seção 4 indicados.

### Guilherme — dados

Ordem de leitura: [import_semob.py](backend/tools/import_semob.py), [database.py](backend/config/database.py), [data.py](backend/repositories/data.py), `backend/tools/verificar_banco.py`, `planejamento/DICIONARIO_DADOS.md`.

- Como o importador escolhe a fonte preferencial quando dois arquivos cobrem o mesmo mês? Explique a tupla da linha 116 e o `max` da linha 117.
- Por que rodar o importador duas vezes não duplica registros? Veja o `_id` da linha 108 e o `ReplaceOne` das linhas 138 a 141.
- O que a view `dados_consulta` filtra e o que ela esconde? Veja o `pipeline` da linha 147.
- Por que um número com vírgula vira `Decimal128` e um sem vírgula vira `int` (linha 62)?
- O que `decimal_value` ([data.py](backend/repositories/data.py#L17)) faz com `bool` e com `float`, e por quê?
- Quais conferências o `upload` faz depois de gravar (linhas 155 a 161)?

Experimentos: M1, M9, M10.

### Isabela — requisitos e rastreabilidade

Ordem de leitura: `planejamento/REQUISITOS.md`, `CASOS_USO_BACKLOG.md`, `RASTREABILIDADE.md`, depois [schemas.py](backend/models/schemas.py) e o teste `test_invalid_filters` em [test_dashboard.py](backend/tests/test_dashboard.py#L87).

- Para cada linha da matriz de rastreabilidade, abra o arquivo e o teste citados e confirme que existem e fazem o que a matriz diz. Anote o que não bater.
- Quais das sete consultas inválidas de `test_invalid_filters` são barradas por qual regra de `Filters` (linhas 21 a 40)?
- Onde, no código, está cada cenário de aceitação de `CASOS_USO_BACKLOG.md`?
- O requisito diz que a comparação exige cobertura completa. Que linha de [dashboard.py](backend/services/dashboard.py#L81) implementa isso?

Experimentos: M4, M8 e o desafio M11.

### Gabriel — API e regras de cálculo

Ordem de leitura: [schemas.py](backend/models/schemas.py), [dashboard.py](backend/services/dashboard.py), [main.py](backend/main.py), `API_CONTRATO.md`.

- Por que cinco rotas diferentes usam a mesma função (linhas 71 a 77)? O que isso garante entre as telas?
- Em que situação a API responde 422, 503 e 404? Aponte a linha de cada uma.
- Para que servem o CORS da linha 37 e o `TrustedHostMiddleware` da linha 39, numa aplicação que só roda em `127.0.0.1`?
- Por que viagens usa `nrViagensRealiz` numa família e `nrViagens` na outra (linhas 65 e 66 de `dashboard.py`)?
- O que acontece com 29/02 na comparação com o ano anterior (linhas 31 a 35)?
- Por que `receita` e `custo` são sempre `None` (linhas 69 e 70)?

Experimentos: M3, M5, M7, M12.

### Rebecca — frontend

Ordem de leitura: [main.dart](frontend/lib/main.dart), [layout_base.dart](frontend/lib/screens/layout_base.dart), [tela_com_filtros.dart](frontend/lib/widgets/tela_com_filtros.dart), `widgets/top_header.dart`, a pasta `repositories/`, a pasta `models/`, `core/format.dart`, e por fim os widgets de cartão e gráfico.

- Quais são as cinco variáveis de estado de `_TelaComFiltrosState` (linhas 54 a 58) e quando cada uma muda?
- O que o usuário vê em cada estado: carregando, erro, sem dados, com dados? Veja `_estado` (linha 248) e `_notice` (linha 233).
- Por que cada tela tem três arquivos de repositório (abstrato, `api_` e `mock_`)?
- Onde exatamente um valor `null` vira o texto "Indisponível"? Encontre o arquivo e a linha.
- Como a navegação entre telas funciona sem rotas de URL? Veja `_tela` em `layout_base.dart` (linha 48).
- Em que largura o layout muda de "largo" para "empilhado"?

Experimentos: os de frontend da seção 4 (exigem Flutter instalado).

### Larissa — relatórios e testes

Ordem de leitura: [reports.py](backend/services/reports.py), as rotas das linhas 79 a 101 de [main.py](backend/main.py#L79), `frontend/lib/screens/relatorios.dart`, [test_dashboard.py](backend/tests/test_dashboard.py), `frontend/test/dashboard_test.dart`.

- Por que o relatório nunca mostra um número diferente da tela? Veja as linhas 87 e 88 de `main.py`.
- Por que `ReportStore.file` (linha 147) confere o identificador com uma expressão regular antes de montar o caminho do arquivo?
- O que acontece se a geração do PDF falhar no meio (linhas 172 a 177)?
- Para que serve `cell.data_type = "s"` (linha 124)?
- O que a fixture `client` (linha 17 de `test_dashboard.py`) faz, e por que os testes não precisam de banco?
- Como `test_mongo_query_projection_and_no_writes` (linha 127) testa a consulta sem conectar ao MongoDB?

Experimentos: M2, M6.

## 4. Experimentos: quebre e veja

Cada experimento é uma mudança de uma linha. **Antes de rodar, escreva qual teste você acha que vai falhar.** Depois rode os testes, compare e desfaça.

Rodar os testes (na raiz do projeto, depois de `Instalar SEMOB.cmd`):

```
.venv/Scripts/python.exe -m pytest -q
.venv/Scripts/python.exe -m unittest discover -s backend/tools -p test_import_semob.py
```

Desfazer a mudança:

```
git restore backend
```

Os resultados abaixo foram conferidos em 16/11/2026, aplicando cada mudança sozinha sobre o código integrado.

| # | Mudança | Onde | Teste que falha | O que isso prova |
| --- | --- | --- | --- | --- |
| M1 | Acrescentar `"valores.Motorista": 1` à projeção | `data.py:69` | `test_mongo_query_projection_and_no_writes` | A consulta não pode pedir o campo Motorista |
| M2 | Trocar a linha por `source = [r for f in families for r in groups[day][f]]` | `dashboard.py:64` | `test_precedence_does_not_double_count` | Somar duas famílias conta o mesmo dia duas vezes |
| M3 | Trocar o `else None` final por `else Decimal(0)` | `dashboard.py:68` | 5 testes, entre eles `test_decimal128_precision_and_missing_field` | Ausência não pode virar zero |
| M4 | Trocar `extra="forbid"` por `extra="ignore"` | `schemas.py:21` | `test_invalid_filters` | Parâmetro desconhecido tem de ser rejeitado |
| M5 | Trocar `{Decimal: str}` por `{Decimal: float}` | `main.py:22` | `test_missing_is_not_zero_and_sales_are_not_revenue` | O decimal precisa viajar como texto exato |
| M6 | Trocar `if data["sem_dados"]:` por `if False:` | `main.py:89` | `test_empty_period_and_empty_export` | Não se gera relatório de período vazio |
| M7 | Acrescentar `or not settings.uri` à condição do `DemoRepository` | `main.py:27` | `test_mongo_unconfigured_is_503_not_demo` | Sem banco, a API erra em vez de mostrar dado fictício |
| M8 | Trocar `< 5` por `< 6` | `dashboard.py:42` | `test_weekdays_and_line_filter` | "Segunda a sexta" exclui o sábado |
| M9 | Trocar `max(items)` por `min(items)` | `import_semob.py:117` | `test_monthly_precedence_totals_and_idempotence` | A eleição da fonte preferencial tem uma ordem definida |
| M10 | Trocar `Decimal128(number)` por `float(number)` | `import_semob.py:62` | `test_decimal_and_identifiers` | O importador não pode gravar ponto flutuante |
| M12 | Trocar a lista de hosts por `["*"]` | `main.py:39` | `test_cors_and_host` | A API só atende endereços locais |

### Desafio M11: o teste que falta

Em `dashboard.py:81`, troque a linha por `comparable = bool(previous) and old_value not in (None, 0)`. Isso remove a exigência de cobertura completa na comparação. **Nenhum teste falha.**

O teste `test_partial_interval_and_no_fabricated_comparison` parece cobrir essa regra, mas no cenário dele o período anterior não tem dado nenhum, então a comparação é omitida por outro motivo. Tarefa: escrever um teste em que o período atual tem lacuna e o anterior está completo, e conferir que ele passa com o código original e falha com a mudança. Quem fizer isso terá corrigido uma falha real de cobertura do projeto.

### Experimentos de frontend

Não foram conferidos por execução, porque exigem Flutter instalado. Rode `flutter test` dentro de `frontend/` antes e depois.

- Em `tela_com_filtros.dart`, remova `|| id != _requisicao` da linha 75. Que defeito isso reintroduz, e como reproduzi-lo à mão?
- Em `json_values.dart`, faça `numeroJson` devolver `0` quando o valor for `null`. O que muda na tela Financeiro, e qual teste de `dashboard_test.dart` deveria pegar isso?
- Na tela Passageiros, o cartão "Composição de demanda" mostra a palavra "Passageiros" quebrada na vertical. Encontre a causa em `widgets/donut_chart_comp.dart` e corrija. A causa ainda não foi diagnosticada.

## 5. Sessão em grupo (1 hora)

1. **Narração (10 min).** Um integrante sorteado narra a trilha comum sem consultar. Os outros corrigem.
2. **Aula de cada módulo (5 × 7 min).** Cada um explica o seu módulo e mostra um experimento ao vivo: muda a linha, roda o teste, mostra a falha.
3. **Pergunta cruzada (15 min).** Cada um responde a uma pergunta da seção 6 sobre um módulo que **não** é o seu. A banca pode perguntar a qualquer um.

Sinal de que o grupo está pronto: qualquer integrante consegue dizer em qual arquivo mexeria para mudar "mês" de 30 para 31 dias, para acrescentar um indicador novo e para acrescentar uma coluna no XLSX.

## 6. Perguntas que a banca pode fazer

| Pergunta | Resposta curta | Onde está |
| --- | --- | --- |
| Como vocês evitam dupla contagem? | Em dois pontos: o importador marca uma fonte preferencial por tipo e mês, e a API usa uma única família de relatório por dia e indicador. | `import_semob.py:114-120`, `dashboard.py:63` |
| Por que não usar `float`? | Ponto flutuante não representa centavos com exatidão. O valor é Decimal128 no banco, `Decimal` no Python e texto no JSON. | `import_semob.py:62`, `data.py:17`, `main.py:22` |
| O que acontece se o banco cair? | A API responde 503 com mensagem genérica, sem expor endereço ou senha, e a tela oferece "Tentar novamente". | `data.py:50-53`, `main.py:49`, `tela_com_filtros.dart:248` |
| A aplicação pode alterar o banco? | Não há rota de escrita, e o repositório só chama `find` e `find_one`. Quem escreve é o importador, que é uma ferramenta separada. | `data.py`, `import_semob.py:127` |
| Como tratam dado pessoal? | A view exclui o campo Motorista e a API nem o solicita. Isso reduz exposição; não é prova de conformidade jurídica completa. | `import_semob.py:147`, `data.py:13` |
| Por que receita aparece "Indisponível"? | Não há fonte validada. Vendas de créditos não equivalem a receita tarifária, por isso aparecem separadas. | `dashboard.py:69-70` |
| O que é "mês" no filtro? | Os 30 dias corridos até a última data com dado, não o mês do calendário. | `dashboard.py:18-22` |
| Por que o relatório bate com a tela? | A geração chama a mesma função de cálculo, com os mesmos filtros. | `main.py:87-88` |
| Como sabem que funciona? | 29 testes de backend e 5 do importador, mais 5 de interface. Cada regra central tem um teste que falha se ela for removida (seção 4). | `backend/tests/` |
| Por que MongoDB? | Os relatórios têm colunas diferentes por tipo; documentos acomodam isso, e o Decimal128 é nativo. | `import_semob.py:108` |

## 7. Pontos de atenção antes da banca

- **Arquivos vazios.** `backend/routes/filtros.py`, `graficos.py`, `kpis.py`, `backend/services/smart_data_sync.py` e os dois arquivos de `frontend/exportação/` têm zero linhas. Não são usados. Saibam dizer isso, ou removam.
- **Comentário desatualizado.** [visao_geral_repository.dart](frontend/lib/repositories/visao_geral_repository.dart#L11) diz "padrão: mock", mas o padrão em `config.dart` é a API.
- **Documento de produto desatualizado.** Ele cita testes do importador com nomes que não existem mais (por exemplo `test_conversoes_decimais_e_identificadores`; o nome atual é `test_decimal_and_identifiers`), fala em exportação PDF/CSV (o código gera PDF/XLSX) e descreve papéis diferentes dos módulos de cada um.
- **Evidência do Atlas.** `RASTREABILIDADE.md` cita `evidencias/real/`, mas essa pasta não está no repositório. Se a banca pedir a evidência da leitura real, ela precisa ser mostrada de outro jeito, por exemplo com a aplicação aberta na base real.
- **Uso de IA.** O `README.md` registra que a implementação teve assistência de IA. Estudar o código é o que torna a apresentação honesta: declarem o uso conforme a regra da disciplina e respondam pelo que cada um de fato entendeu.
