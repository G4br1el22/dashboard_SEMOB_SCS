# Plano de trabalho SEMOB — proposta para cinco integrantes

**Atualização de execução:** o usuário definiu trabalho sequencial, com Guilherme primeiro. A ordem operacional, os prompts completos e os critérios de repasse estão em [ROTEIRO_SEQUENCIAL_IAS_SEMOB.md](ROTEIRO_SEQUENCIAL_IAS_SEMOB.md). Esse roteiro substitui as orientações de paralelismo e as branches sugeridas nas seções 4 a 6 abaixo; o inventário de fontes e o diagnóstico continuam como referência.

Situação: rascunho baseado no código e nos materiais efetivamente consultados. Não constitui rubrica do professor nem atribuição já aceita pelos integrantes. Nenhuma implementação ou publicação foi realizada para produzir este plano.

## 1. Fontes e limites da pesquisa

- Dashboard: G4br1el22/dashboard_SEMOB_SCS, commit d9bcc17ae2a0f7d8e4fd94ae756fc8ac6fc9f0ec. Branch local disponível: feat/finalizacao-dashboard-semob.
- Estudos: Gnune2/estudos, commit 15cc9976149aeda97499ab27262f1ed52f28f0de. Consultados README, acervo/CATALOGO.md, acervo/manifesto.json, trechos do protocolo output/protocolo-modelagem/protocolo-modelagem-negocio-software.md e síntese output/pdf/engenharia-de-software-cola.md.
- Seis PDFs originais recuperados do commit b064adb571ac4ad813a1b1c2efe11a818edeea65 de estudos. Os seis SHA-256 foram conferidos com o manifesto. Foram lidas páginas selecionadas, não a íntegra de todos os PDFs:
  - M1: TTI1004 T03 — Modelagem de Processos I, páginas PDF 6–8: objetivos, processos e BPMN As-Is.
  - M2: TTI1004 T05 — Engenharia de Requisitos I, páginas PDF 7–10: elicitação e evidências.
  - M3: TTI1004 T06 — Engenharia de Requisitos II, páginas PDF 55–57: processo → requisito → caso de uso.
  - E1: TTI205 Lab02 — Documento de Visão, páginas PDF 2–6: responsabilidades, visão e demonstração do software.
  - E2: TTI205 Lab06a — Arquitetura, páginas PDF 6–8 e 28–29: camadas, diagramas e apresentação.
  - E3: TTI205 Lab07 — Estratégias de Testes, páginas PDF 2–7: especificação, execução e relatório de testes.
- Esses laboratórios têm enunciados próprios. O exercício de busca de números, o uso de Java e a quantidade de participantes indicada em E3 NÃO são exigências confirmadas para o SEMOB.
- Pasta do Drive fornecida: https://drive.google.com/drive/folders/1tBcYhHORLjvo3suhSdewL76U9Ia8mxce . A consulta foi recusada pelo proxy com HTTP 403. Não foi possível listar seu conteúdo. A pasta do acervo referenciada no README de estudos tem outro ID; não foi assumida como sendo a mesma.
- Procurados termos SEMOB, TTI206, projeto integrador, enunciado, rubrica, prazo e cronograma nos textos disponíveis, no catálogo de 539 caminhos e nos nomes de arquivos do histórico acessível. O histórico do dashboard está completo; o de estudos foi aprofundado em oito commits. Não foi localizado enunciado ou prazo específico do SEMOB nesse conjunto. Os cronogramas encontrados pertencem a outras disciplinas; não servem para inventar o prazo deste projeto.

Os PDFs recuperados estão em /tmp/semob-fontes-aulas e a cópia de consulta de estudos em /tmp/gnune2-estudos. São arquivos temporários desta máquina; os links Git abaixo permitem retomar a consulta.

Fontes permanentes:
- https://github.com/Gnune2/estudos/blob/15cc9976149aeda97499ab27262f1ed52f28f0de/acervo/CATALOGO.md
- https://github.com/Gnune2/estudos/tree/b064adb571ac4ad813a1b1c2efe11a818edeea65
- https://github.com/G4br1el22/dashboard_SEMOB_SCS/tree/d9bcc17ae2a0f7d8e4fd94ae756fc8ac6fc9f0ec

## 2. Diagnóstico confirmado

- Há telas Flutter para visão geral, passageiros, frota/viagens, financeiro, linhas e relatórios, com interfaces de repositório, implementações mock e clientes HTTP.
- USE_MOCK é verdadeiro por padrão. Existência de tela ou cliente HTTP não comprova integração real.
- main.py, config/database.py, models/schemas.py, routes existentes e services/smart_data_sync.py estão vazios. O backend da aplicação precisa ser implementado.
- Os clientes esperam GET /api/visao-geral, /api/passageiros, /api/frota-viagens, /api/financeiro, /api/linhas e /api/relatorios; POST /api/relatorios/gerar; GET /api/relatorios/{id}/download.
- API_CONTRATO.md é citado no Dart, mas não existe no checkout. Os métodos fromJson e toQuery são a referência técnica inicial a conferir com as necessidades reais.
- O importador possui cinco testes, aprovados na preparação do ambiente. Ele grava no banco semob, coleções relatorios_origem e relatorios_linhas, e cria a view dados_consulta. Isso descreve o código; a estrutura efetiva do Atlas ainda precisa ser confirmada.
- A view exclui totais não diários, fontes não preferenciais e determinados dados brutos. Agregar a coleção bruta sem considerar essas regras pode duplicar resultados.
- O usuário informou que o banco está no Atlas; a imagem mostra o cluster semob-dev. A conexão deste ambiente não foi testada.
- Há inconsistências Flutter: pubspec.yaml na raiz e fontes em frontend/; intl ^0.19.0 no manifesto e 0.20.3 nos lockfiles. Instalação, análise, teste e build Flutter não foram concluídos.

## 3. Objetivo e escopo propostos

Entregar um dashboard que consulte os dados existentes, explique a origem de seus indicadores e permita demonstrar um fluxo real de ponta a ponta, acompanhado de documentação coerente com as aulas.

Prioridade inicial: uma consulta por período com dados reais, filtros verificáveis, tratamento de ausência de dados e cálculo conciliado com a base. Expandir para as telas já existentes conforme prazo e evidências. Não prometer todas as telas concluídas sem estimar o trabalho restante.

Relatórios entram no incremento seguinte. E-mail automático, coleta automática no Smart Data, autenticação adicional e novas funcionalidades ficam sujeitos a confirmação de necessidade e exigência acadêmica. Não anunciar automação que não existe.

Não inventar custo, ocupação, pontualidade ou receita por falta de fonte. Ausência de informação deve ser representada como indisponível, com ajuste explícito e coordenado no contrato e na interface. Zero só representa zero observado ou regra documentada, nunca substituição silenciosa de dado ausente.

## 4. Divisão sugerida

Os nomes vêm do README do grupo e podem ser trocados sem mudar as responsabilidades.

### Guilherme (Gnune2) — dados e MongoDB

Branch sugerida: feat/dados-mongodb.

Responsabilidades:
- Confirmar banco, coleções, view, tipos, datas e período efetivamente disponível com acesso autorizado de leitura.
- Documentar dicionário de dados, relação campo → indicador, regras de fonte preferencial e limites de qualidade.
- Implementar conexão e camada de consulta em backend/config/database.py e novos módulos backend/repositories/.
- Verificar consultas e explicar conversão de Decimal128 e tratamento de datas; não somar estoques/saldos como fluxos sem regra de negócio.
- Manter o importador e seus testes. Nova carga, alteração de índices ou mudança de view só se necessária e autorizada; o banco existente não precisa ser reimportado por padrão.

Entrega: dicionário, acesso reutilizável aos dados, exemplos anonimizados e conciliação reproduzível de um indicador com uma consulta de referência.

Conclusão: conexão de leitura comprovada, consulta sem duplicidade e testes de transformação aprovados. Credenciais apenas em configuração segura do backend.

### Gabriel — API e indicadores

Branch sugerida: feat/api-indicadores.

Responsabilidades:
- Criar aplicação FastAPI, inicialização, configuração de CORS para o frontend e endpoint de saúde; centralizar backend/main.py, models/schemas.py e requirements.txt.
- Consolidar API_CONTRATO.md a partir dos modelos Dart e dos requisitos de Isabela, com exemplos JSON, erros, datas, filtros e valores indisponíveis.
- Implementar indicadores e rotas de consulta usando a camada de Guilherme. Compartilhar serviços de cálculo para evitar regras diferentes entre telas.
- Definir semântica de dia, semana, quinzena, mês, intervalo, comparação e dias úteis. Esclarecer fuso, referência de data, feriados, denominador zero e ausência de período comparável.
- Integrar os routers e dependências dos demais PRs; alterações em main.py e requirements.txt passam por este responsável.

Entrega: API documentada, rotas priorizadas, cálculos rastreáveis e testes de filtros/agregação/contrato.

Conclusão: JSON aceito pelo Dart, números conciliados e comportamento conhecido para intervalo vazio, datas inválidas e falha de conexão.

### Isabela — negócio, requisitos e modelagem

Branch sugerida: docs/negocio-requisitos.

Responsabilidades:
- Inventariar a documentação real e manter a matriz de exigências acadêmicas, separando obrigação confirmada de recomendação.
- Preparar Documento de Visão: problema, stakeholders, objetivos, MVP, escopo e limites. O README é evidência da proposta do grupo, não prova de entrevista com a SEMOB.
- Descrever processo atual e proposto; produzir BPMN quando aplicável, com fonte editável e revisão da notação.
- Organizar RF, RNF, regras de negócio, casos de uso, histórias e critérios de aceitação com identificadores estáveis.
- Manter rastreabilidade necessidade → requisito → tela/serviço → teste. Revisar os documentos com os responsáveis técnicos.

Entrega: documentação de negócio e requisitos que permita explicar por que cada parte do software existe. Selecionar UML e demais artefatos conforme sua utilidade e o enunciado, sem produzir todos os diagramas automaticamente.

Conclusão: cenários normais e falhas importantes especificados, fontes registradas e pendências visíveis; nenhuma entrevista ou aprovação fictícia.

### Rebecca — frontend e experiência de uso

Branch sugerida: feat/frontend-integracao.

Responsabilidades:
- Resolver estrutura Flutter e incompatibilidade manifesto/lockfiles, escolher e registrar SDK compatível e validar instalação reproduzível. Esta é uma tarefa de código futura, não uma mudança já feita no onboarding.
- Manter frontend/lib/, frontend/test/, frontend/web/ e os manifests/lockfiles Flutter; evitar alterações simultâneas desses arquivos por outras pessoas.
- Integrar clientes HTTP com a API real via USE_MOCK=false e API_BASE_URL; preservar um modo de demonstração identificado.
- Verificar filtros, navegação, datas, formatação, responsividade e estados carregando/vazio/erro/sucesso.
- Conferir o conteúdo das telas com Isabela e os campos da API com Gabriel. Remover afirmações enganosas de envio de e-mail ou sincronização automática caso permaneçam sem implementação.

Entrega: fluxo web navegável usando API real, jornada/mapa de telas coerentes e testes de interação relevantes.

Conclusão: build, análise e testes executados, um filtro alterando resultados reais e falha de API apresentada de forma compreensível. Registrar resultados reais, inclusive falhas remanescentes.

### Larissa — relatórios, verificação de ponta a ponta e entrega

Branch sugerida: feat/relatorios-validacao.

Responsabilidades:
- Implementar módulo backend/routes/relatorios.py e serviço de exportação, reutilizando os cálculos de Gabriel. Coordenar dependências e registro do router com ele.
- Fazer listagem, geração e download reais conforme contrato. Fechar um formato funcional primeiro; formatos anunciados na UI precisam funcionar ou ser retirados do escopo de forma explícita.
- Especificar consistência de período/filtros entre relatório e dashboard; qualquer mudança na chamada gerar(tipoId) deve ser combinada no contrato e no frontend.
- Coordenar matriz de testes e roteiro de demonstração sem assumir a responsabilidade pelos testes unitários de todo o grupo.
- Consolidar evidências, limitações, instruções de execução e apresentação com contribuição dos cinco integrantes.

Entrega: relatório que abre e possui dados conciliáveis, verificação de ponta a ponta e roteiro de apresentação.

Conclusão: arquivo válido com conteúdo correto, download inexistente tratado e demonstração reproduzível sem depender de dados fictícios ocultos.

## 5. Ordem de execução e pontos de integração

1. Base comum: Isabela consolida o escopo; Guilherme confirma os dados; Gabriel e Rebecca acordam o contrato. Publicar exemplos JSON anonimizados e critérios de aceitação antes de implementar fluxos dependentes. Larissa prepara os cenários de teste.
2. Desbloqueios paralelos: Guilherme implementa leitura; Gabriel prepara a API; Rebecca corrige o ambiente Flutter; Isabela desenvolve os modelos; Larissa implementa exportação sobre fixtures aderentes ao contrato.
3. Primeiro incremento: integrar uma consulta MongoDB → API → tela, conferir um número e percorrer sucesso, vazio e erro. Revisar com o grupo antes de ampliar as telas.
4. Ampliação: acrescentar indicadores e telas priorizados, depois relatórios. Atualizar documentação e testes junto com cada incremento.
5. Fechamento: conciliar números, revisar rastreabilidade, executar roteiro, registrar falhas e ensaiar a apresentação dos cinco.

Sem prazo localizado, estas são etapas por dependência, não um cronograma com datas ou estimativas inventadas. Estimar cada tarefa com os integrantes depois de confirmar disponibilidade e rubrica; reservar tempo de integração.

## 6. Uso de Git e IA sem conflitos

- Cada pessoa trabalha em seu próprio clone ou ambiente e em uma branch própria, baseada no mesmo commit de integração. Não são necessários worktrees para este plano.
- A branch de integração definida no roteiro sequencial é feat/finalizacao-dashboard-semob. As branches das cinco etapas serão criadas durante a execução; a publicação deste plano não executa essas etapas.
- Um PR por entrega revisável; outra pessoa verifica código/documentação e evidências antes da integração. Atualizar a branch com a base comum quando necessário.
- Gabriel é dono dos pontos centrais da API; Rebecca dos manifests Flutter; Guilherme do acesso ao banco. As demais pessoas propõem mudanças nesses pontos por PR coordenado.
- Todos escrevem testes da própria tarefa e explicam suas decisões. Larissa coordena integração; Isabela coordena coerência documental.
- Não enviar credenciais, dados pessoais ou bases restritas aos prompts. Usar dados sintéticos ou amostras anonimizadas.
- IA pode ajudar a analisar, gerar, testar e revisar. Não equivale a revisão humana nem a teste executado. Cada integrante precisa conseguir defender a própria contribuição.

Prompt comum para cada IA:

> Leia o plano, o Documento de Visão, os requisitos, o contrato da API e os arquivos da minha responsabilidade. Informe o que realmente leu. Minha frente é [nome da frente]. Trabalhe somente no escopo desta tarefa: [entrega]. Reutilize o código existente e mantenha os nomes e contratos acordados. Não invente dados, entrevistas, requisitos aprovados ou resultados de testes. Antes de alterar arquivos compartilhados, mostre a dependência e proponha a coordenação necessária. Implemente em incrementos revisáveis, execute os testes adequados quando possível e registre comandos, resultados e limitações. Entregue também uma explicação que eu consiga apresentar ao professor. As regras específicas de uso de IA do SEMOB ainda precisam ser confirmadas; não transfira regras de exercícios diferentes automaticamente.

Complemento de Guilherme: mapear dados_consulta e provar ausência de dupla contagem com consulta reproduzível.

Complemento de Gabriel: derivar contrato dos fromJson e filtros, testar semântica temporal e cálculo sem comparação disponível.

Complemento de Isabela: manter cada exigência com fonte; diagramas devem representar o SEMOB, não copiar atores dos exemplos das aulas.

Complemento de Rebecca: verificar Flutter antes de alterar telas; integrar um fluxo real e testar estado vazio e erro de rede.

Complemento de Larissa: conferir conteúdo de arquivo exportado contra o mesmo período da API; separar testes planejados dos executados.

## 7. Critério comum de conclusão

Para cada item: origem no requisito; responsável; artefatos/código; critérios de aceitação; teste e evidência; revisão por colega; limitações; integração na base comum. Documentação e implementação devem descrever o mesmo comportamento.

Métricas propostas: requisitos do escopo com evidência de teste, itens concluídos por etapa e defeitos abertos por gravidade. Definir denominador e distinguir testes aprovados, falhos, bloqueados e não executados. Não usar linhas geradas pela IA como medida de contribuição.

## 8. Pendências acadêmicas e de acesso

- Enunciado, rubrica, modelo de entrega, prazo e política específica de IA do SEMOB: não localizados nas fontes acessíveis. Continuar pesquisa na pasta do Drive quando houver acesso; não atribuir ao professor as recomendações deste documento.
- Drive: falta acesso de rede nesta sessão e não há ferramenta conectada para pesquisar o conteúdo privado. Não há evidência de que mudar compartilhamento dos arquivos resolva esse bloqueio.
- Atlas: confirmar configuração segura e permissões antes de testar leitura. Nenhuma alteração do banco de produção está autorizada por este plano.
- Build Flutter: permanece pendente; não há evidência de dashboard integrado em funcionamento.
- Revisar distribuição e prazo com o grupo; os nomes e o escopo desta divisão são propostas.
