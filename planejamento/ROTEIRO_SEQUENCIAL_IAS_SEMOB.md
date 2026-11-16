# SEMOB — roteiro sequencial para as cinco pessoas e suas IAs

Esta versão substitui a execução paralela do plano anterior. A ordem definida é: **1 Guilherme (Gnune2) → 2 Isabela → 3 Gabriel → 4 Rebecca → 5 Larissa**. Uma etapa começa a partir da entrega integrada da anterior. Este documento é um plano; nenhuma dessas implementações foi executada para escrevê-lo.

## Como passar o trabalho de uma pessoa para outra

1. A base comum é a branch `feat/finalizacao-dashboard-semob`. Cada IA deve conferir se está nessa base atualizada antes de criar a branch da sua etapa; não presumir que master contém o roteiro.
2. Cada integrante usa seu próprio clone/ambiente. Cria sua branch a partir da versão mais recente da base comum, nunca de uma cópia antiga de master.
3. A IA lê os arquivos existentes, preserva o trabalho anterior e executa a etapa indicada abaixo. Não manda outra IA reconstruir o projeto do zero.
4. A pessoa revisa os resultados e entende o que será apresentado. O código/documentação entra na base comum por PR revisado. A pessoa seguinte começa somente após essa integração. Este plano não autoriza publicação, deploy ou alteração de dados do Atlas.
5. Cada IA atualiza `planejamento/PASSAGEM.md` com: etapa, commit-base e commit de entrega quando disponível, arquivos alterados, decisões, comandos executados e resultados, limitações, próximos passos e instruções para reproduzir.
6. Quando uma verificação não puder ser feita, registrar **bloqueada/não executada**, nunca aprovada. Se impedir o objetivo da etapa, ela continua pendente. Documento escrito não substitui software executado.

Os caminhos `planejamento/` abaixo são propostas de organização dos novos documentos. Evitamos `docs/`, pois essa pasta é ignorada pelo `.gitignore` atual. As cinco branches de execução abaixo são sugestões; o plano não as cria automaticamente.

## Fontes comuns para todas as IAs

- Produto: https://github.com/G4br1el22/dashboard_SEMOB_SCS
- Estudos: https://github.com/Gnune2/estudos
- Guia: `output/protocolo-modelagem/protocolo-modelagem-negocio-software.md`, no repositório de estudos.
- Catálogo de fontes: `acervo/CATALOGO.md` e `acervo/manifesto.json`, no repositório de estudos.
- As aulas consultadas tratam de processos BPMN, requisitos, casos de uso, documento de visão, arquitetura em camadas e testes. As referências detalhadas e limites de acesso estão em `PLANO_EQUIPE_SEMOB.md`, entregue junto deste roteiro.
- Os PDFs removidos do checkout de estudos podem ser consultados no histórico, commit `b064adb571ac4ad813a1b1c2efe11a818edeea65`, com conferência dos hashes do manifesto. Outra máquina não deve presumir que nossos arquivos temporários em `/tmp` existem.
- O prazo, a rubrica e a política específica de IA do SEMOB ainda não foram localizados. Não transformar exercícios diferentes em exigências deste projeto. Não mudar a tecnologia para Java por ela aparecer em um laboratório.

## 1. Guilherme — preparar dados e base do projeto

**Branch:** `feat/01-base-dados`.

**Entrada:** código atual, materiais acessíveis e configuração segura do MongoDB. Seu objetivo é deixar uma base verificável para o grupo, sem implementar as telas ou a API completa.

**A IA deve executar, nesta ordem:**

1. Conferir branch, mudanças existentes, README, importador, testes e fontes de estudo. Registrar o que já existe e o que ainda é proposta.
2. Criar `planejamento/FONTES.md`, `planejamento/ESTADO_INICIAL.md` e `planejamento/PENDENCIAS.md`. Procurar o enunciado nas fontes disponíveis; registrar o resultado e a limitação de acesso ao Drive, sem inventar prazo.
3. Inspecionar nomes e presença das configurações de banco antes de pedir novos dados. Configurar conexão somente no backend, usando variáveis como `MONGODB_URI` e `MONGODB_DB`, conforme o mecanismo seguro do ambiente. Nunca colocar valores secretos no código, no Git ou na conversa. Caso o ambiente não ofereça o tipo de credencial/conectividade necessário, registrar o bloqueio específico.
4. Implementar `backend/config/database.py`, um comando de verificação de leitura em `backend/tools/verificar_banco.py`, a declaração das dependências necessárias e `backend/.env.example` contendo apenas nomes e placeholders. Não criar uma segunda convenção de configuração se o projeto já tiver uma válida.
5. Com acesso de leitura autorizado, verificar ping, banco, coleções/view, tipos de campos, intervalo de datas e contagens relevantes. Confirmar se existem `semob`, `relatorios_origem`, `relatorios_linhas` e `dados_consulta`; são nomes usados pelo importador, não fatos já comprovados no Atlas.
6. Criar `planejamento/DICIONARIO_DADOS.md` e `planejamento/INDICADORES_DISPONIVEIS.md`. Para cada indicador das telas, registrar campo de origem, tipo, unidade, regra de agregação e situação: disponível, derivável ou ausente. Proteger identificadores e dados pessoais nas evidências.
7. Definir a interface da camada de leitura em `backend/repositories/` e implementá-la com filtros de data/tipo necessários. Preservar as regras de fonte preferencial e exclusão de totais; não criar, atualizar, apagar ou reimportar dados remotos nesta etapa.
8. Executar os testes existentes do importador e testes pertinentes à conexão/configuração e às transformações. Conciliar pelo menos um total com consulta independente de referência. Registrar comandos de leitura e resultados, sem expor dados restritos.
9. Atualizar `planejamento/PASSAGEM.md` com instruções para Isabela e as limitações de dados a considerar nos requisitos.

**Entrega mínima:** conexão de leitura reutilizável, dicionário, mapa de indicadores, verificação reproduzível e passagem. Se o Atlas continuar inacessível, a confirmação de dados permanece bloqueada; não apresentar o esquema inferido como validado.

**Prompt para copiar:**

> Sou Guilherme, Gnune2. Execute somente a etapa 1 do ROTEIRO_SEQUENCIAL_IAS_SEMOB.md, na ordem descrita. Leia o código e os materiais realmente acessíveis; preserve alterações existentes. Prepare a base documental e a leitura segura do MongoDB, confirme o esquema e a origem dos indicadores, execute as verificações e registre os resultados. Não altere dados remotos, não implemente a API ou o frontend e não exponha credenciais. Se algo bloquear a leitura real, explique a causa comprovada e marque a entrega afetada como pendente. Ao terminar, entregue o diff revisável, a lista de comandos/resultados, uma explicação para eu defender na apresentação e a passagem para Isabela. Não publique nem integre a branch automaticamente.

## 2. Isabela — definir exatamente o que será entregue

**Branch:** `docs/02-requisitos-modelagem`.

**Entrada:** entrega integrada de Guilherme, especialmente o dicionário e a disponibilidade de indicadores. Seu objetivo é fixar o escopo e os critérios que orientarão o código.

**A IA deve executar, nesta ordem:**

1. Ler `planejamento/PASSAGEM.md`, fontes, pendências, dicionário e telas atuais. Separar fatos do README, dados verificados, hipóteses e decisões propostas.
2. Criar `planejamento/MATRIZ_EXIGENCIAS.md`: exigência, fonte/página, artefato, responsável, situação e evidência. Sem rubrica, identificar os itens como recomendações, sem fabricar obrigações do professor.
3. Produzir `planejamento/VISAO_ESCOPO.md`: problema, stakeholders, objetivos, MVP, escopo incluído/excluído e restrições. O fluxo prioritário deve ser uma consulta real por período; definir quais das telas existentes compõem a entrega.
4. Descrever o processo atual e proposto em `planejamento/PROCESSOS.md`. Produzir BPMN As-Is/To-Be com fonte editável em `planejamento/modelos/` quando aplicável. Informações não confirmadas sobre a operação atual devem permanecer hipóteses.
5. Criar `planejamento/REQUISITOS.md` com RF, RNF e regras de negócio identificados, origem, prioridade e aceitação. Especificar datas, períodos, comparações, dias úteis e dados ausentes. Não exigir indicadores que a etapa 1 mostrou não terem fonte sem registrar uma decisão de escopo.
6. Criar `planejamento/CASOS_USO_BACKLOG.md`: atores, fronteira, fluxos principal/alternativos, histórias ordenadas e cenários Dado/Quando/Então. Incluir consulta sem resultado, data inválida, indisponibilidade da API/banco e relatório inexistente.
7. Selecionar os modelos UML úteis ao escopo: classes conceituais e sequência de uma consulta, por exemplo. Produzir representação e fonte editável, com multiplicidades e responsabilidades revisadas. Outros diagramas só entram por exigência ou necessidade justificada.
8. Criar `planejamento/RASTREABILIDADE.md` e `planejamento/CRITERIOS_ENTREGA.md`, vinculando requisito → caso de uso → tela/serviço → teste previsto. Definir formatos e conteúdo mínimo dos relatórios; não prometer envio automático por e-mail sem requisito e implementação correspondentes.
9. Entregar um backlog fechado para Gabriel e registrar decisões propostas que ainda precisem de validação do grupo. Atualizar a passagem.

**Entrega mínima:** escopo implementável, regras sem contradição conhecida, critérios verificáveis, modelos selecionados e rastreabilidade. Não modificar o código nesta etapa.

**Prompt para copiar:**

> Sou Isabela. Leia a entrega integrada da etapa 1 e execute somente a etapa 2 do roteiro. Aplique os conceitos das aulas de Modelagem de Negócio e Software e Engenharia de Software ao SEMOB. Produza os documentos e modelos efetivos, com fontes e identificadores estáveis. Defina o escopo e a aceitação usando os dados disponíveis, sem inventar entrevistas, rubrica ou aprovação. Não altere o código nem transforme exemplos das aulas em requisitos do SEMOB. Entregue uma revisão de coerência, os pontos que exigem decisão humana e a passagem para Gabriel. Não publique nem integre a branch automaticamente.

## 3. Gabriel — implementar o backend conforme os requisitos

**Branch:** `feat/03-api-indicadores`.

**Entrada:** documentos de Isabela e camada de dados de Guilherme. Seu objetivo é entregar a API de consulta real e preparar o contrato de relatórios para as duas pessoas seguintes.

**A IA deve executar, nesta ordem:**

1. Ler a passagem e os critérios; conferir todos os `fromJson`, repositórios HTTP e `FiltrosDashboard.toQuery()` do Flutter.
2. Criar `API_CONTRATO.md` na raiz com URLs, métodos, parâmetros, campos, tipos, nulabilidade, exemplos anonimizados e erros. Preservar nomes existentes quando compatíveis; justificar e registrar mudanças necessárias nos consumidores Dart.
3. Definir o contrato de geração/listagem/download dos relatórios com base no escopo de Isabela. Especificar os filtros do relatório, formato, ID e conteúdo; Larissa implementará o serviço na etapa 5. Não retornar sucesso fictício para funcionalidades ainda ausentes.
4. Implementar FastAPI em `backend/main.py`, schemas em `backend/models/`, configuração por ambiente e CORS. Atualizar `backend/requirements.txt` com instalação reproduzível. Separar verificação do processo de verificação de disponibilidade do banco, sem expor detalhes sensíveis em erros.
5. Implementar serviços compartilhados de datas/agregação e as rotas do escopo: `/api/visao-geral`, `/api/passageiros`, `/api/frota-viagens`, `/api/financeiro`, `/api/linhas`. Reutilizar a camada de Guilherme. Qualquer exclusão de rota depende do escopo documentado, não de silêncio.
6. Garantir consistência temporal: limites inclusivos/exclusivos documentados, referência de data, fuso, períodos de comparação, dias úteis e granularidade. Não rotular série diária como horária. Tratar divisor zero e comparação ausente sem percentual inventado.
7. Representar indicadores sem fonte como indisponíveis conforme o contrato; registrar os ajustes de UI que Rebecca deve fazer. Não preencher custo, ocupação ou pontualidade com números demonstrativos na API real.
8. Criar e executar testes de serviços, filtros e respostas. Usar fixtures sintéticas para testes reproduzíveis e uma verificação real de leitura/rota no Atlas autorizado. Conciliar números com as consultas de referência da etapa 1.
9. Iniciar a API, fazer requisições funcionais de sucesso/vazio/erro e documentar os comandos em `planejamento/EXECUCAO_BACKEND.md`. Atualizar rastreabilidade e passagem com exemplos de respostas para Rebecca e especificação de relatórios para Larissa.

**Entrega mínima:** rotas do escopo executáveis, JSON documentado, cálculo conciliado e testes registrados. Relatórios continuam identificados como pendentes da etapa 5; o backend de consulta não pode depender de um módulo de relatórios que ainda não existe.

**Prompt para copiar:**

> Sou Gabriel. Execute somente a etapa 3, lendo antes a passagem e as entregas 1 e 2. Implemente a API real em FastAPI reutilizando o acesso MongoDB e respeitando o escopo. Derive e documente o contrato a partir dos modelos Dart e dos requisitos; registre explicitamente qualquer ajuste necessário no frontend. Prepare o contrato dos relatórios, mas deixe sua implementação para Larissa. Não invente métricas ou respostas de sucesso. Execute testes e requisições reais quando houver acesso, registre evidências e explique os cálculos. Entregue a passagem para Rebecca e os detalhes de relatórios para Larissa. Não publique nem integre a branch automaticamente.

## 4. Rebecca — conectar e concluir o frontend

**Branch:** `feat/04-frontend-real`.

**Entrada:** API de Gabriel funcionando, contrato e requisitos. Seu objetivo é fazer o usuário percorrer as telas do escopo com dados reais.

**A IA deve executar, nesta ordem:**

1. Ler a passagem, o contrato, os critérios e os ajustes Dart indicados por Gabriel. Conferir a API antes de tratar um erro de backend como defeito visual.
2. Resolver a localização do `pubspec.yaml` e a divergência do `intl` com os lockfiles por uma alteração de código revisável. Escolher e registrar uma versão compatível de Flutter/Dart, gerar lockfile consistente e validar instalação. Preservar verificações TLS e checksums.
3. Corrigir modelos, parsers e repositórios HTTP conforme o contrato, incluindo tipos e valores indisponíveis; criar testes de parsing para respostas representativas.
4. Executar com `USE_MOCK=false` e `API_BASE_URL` apontando para a API. Manter modo mock explicitamente identificado para demonstração, sem fallback silencioso para números fictícios quando a API falhar.
5. Conferir navegação e as telas priorizadas; ligar filtros ao backend e verificar data/legenda/valor. Ajustar carregamento, lista vazia, dados indisponíveis, erro e nova tentativa; verificar responsividade.
6. Adequar a tela de relatórios ao contrato já especificado, inclusive os filtros acordados. Como o serviço ainda será entregue por Larissa, testar o cliente com fixtures e deixar indisponibilidade explícita; não apresentar exportação como integrada neste ponto.
7. Remover ou corrigir textos de e-mail automático, atualização em tempo real e sincronização caso essas capacidades não existam no escopo implementado.
8. Executar análise, testes Flutter relevantes e build web. Realizar uma consulta real com filtro e comparar um valor visível à resposta da API. Exercitar API indisponível e período vazio. Registrar eventuais falhas remanescentes separadamente dos testes aprovados.
9. Escrever `planejamento/EXECUCAO_FRONTEND.md`, atualizar mapa de telas/jornada, rastreabilidade e passagem. Deixar comandos exatos de execução para Larissa.

**Entrega mínima:** Flutter reproduzível e fluxo web real de consulta validado. Relatórios ainda aguardam o backend da etapa 5; esse limite deve constar na passagem.

**Prompt para copiar:**

> Sou Rebecca. Execute somente a etapa 4 sobre a versão integrada de Gabriel. Primeiro leia o contrato e resolva a instalação Flutter; depois integre os modelos, clientes e telas à API real. Preserve as regras e o design existente onde atendem ao escopo, e trate dados indisponíveis explicitamente. Implemente o cliente de relatórios contra o contrato, mas identifique que sua integração final depende da etapa 5. Execute análise, testes, build e a verificação funcional de consulta real; não declare como executado o que ficou bloqueado. Entregue comandos reproduzíveis, evidências, explicação das alterações e a passagem para Larissa. Não publique nem integre a branch automaticamente.

## 5. Larissa — concluir relatórios, integrar e preparar a apresentação

**Branch:** `feat/05-relatorios-entrega`.

**Entrada:** dados, requisitos, API e frontend integrados. Seu objetivo é concluir a última funcionalidade e verificar a entrega como um todo.

**A IA deve executar, nesta ordem:**

1. Ler a passagem, executar os comandos de backend/frontend e reproduzir a consulta real já validada. Registrar regressões antes de acrescentar código.
2. Implementar `backend/routes/relatorios.py`, o serviço correspondente e o registro em `backend/main.py`, conforme o contrato. Atualizar dependências para os formatos definidos no escopo.
3. Implementar listagem, geração e download real. Definir armazenamento de arquivos/metadados adequado ao ambiente e documentado; evitar escrita no Atlas existente por padrão. Se persistência remota for necessária, tratar autorização e coleção de destino antes da escrita.
4. Reutilizar os mesmos filtros e serviços de cálculo da API. O arquivo precisa informar período, unidades, origem dos dados e limitações. Não criar totais ou seções com números fictícios.
5. Validar abertura e conteúdo dos arquivos, tipo de mídia, nome, listagem e download inexistente. Integrar a tela de Rebecca ao serviço real e corrigir diferenças de contrato documentando o impacto.
6. Executar o roteiro completo: iniciar serviços → abrir dashboard em modo real → consultar período conhecido → alterar filtro → verificar estado vazio/erro → gerar relatório → baixar e abrir → conciliar os valores com a tela e a consulta de referência.
7. Rodar as suítes existentes e as acrescentadas nas etapas, análise e build Flutter. Cada integrante continua responsável pelas falhas da própria frente; Larissa registra e coordena correções, sem ocultar testes falhos para encerrar a entrega.
8. Consolidar `planejamento/RESULTADOS_TESTES.md`: identificador, requisito, entrada, resultado esperado/observado, comando, situação e evidência. Atualizar rastreabilidade e separar aprovado, falho, bloqueado e não executado.
9. Revisar README e comandos de instalação/execução, `.env.example`, arquitetura e modelos para refletirem a implementação final. Preparar `planejamento/RELATORIO_FINAL.md`, adaptado ao modelo do professor se localizado, com fontes, contribuição de IA, limitações e resultados reais.
10. Criar `planejamento/APRESENTACAO.md`: Guilherme explica dados e conciliação; Isabela apresenta problema/processos/requisitos; Gabriel demonstra API e regras; Rebecca demonstra navegação/filtros/erros; Larissa demonstra relatório e evidências de testes. Incluir roteiro de ensaio, sem inventar tempo de apresentação.
11. Encerrar a passagem com versão final, capacidades demonstradas, pendências e checklist para revisão do grupo. Não declarar que o trabalho atende integralmente à rubrica enquanto ela continuar desconhecida.

**Entrega mínima:** relatórios funcionais do escopo, fluxo completo reproduzível, testes/evidências consolidados e documentação coerente. Publicação ou apresentação efetiva não são presumidas concluídas.

**Prompt para copiar:**

> Sou Larissa. Execute somente a etapa 5 sobre a versão integrada de Rebecca. Reproduza primeiro o fluxo existente; implemente os relatórios conforme o contrato, reutilizando as regras da API, e conclua sua integração ao Flutter. Teste geração, download, abertura e conteúdo, conciliando números com a tela. Execute o roteiro completo e as verificações do projeto, registre resultados verdadeiros, organize correções e consolide documentação e apresentação dos cinco integrantes. Não altere dados remotos ou publique sem autorização específica. Entregue diff revisável, evidências, limitações e checklist final para o grupo. Não integre a branch automaticamente.

## O que todos precisam receber ao iniciar

- Este roteiro e o inventário de fontes do plano inicial.
- Link e branch da versão integrada mais recente, com o commit de entrada.
- `planejamento/PASSAGEM.md` atualizado e documentos produzidos até então.
- Acesso às fontes efetivamente necessárias; um caminho temporário de outra máquina não basta.
- Configuração segura do ambiente para quem precisa executar o banco; a URI nunca vai no prompt.

As etapas e prompts são instruções para futuras sessões de trabalho. Não são afirmações de que o código, os documentos internos propostos ou os testes adicionais já existem.
