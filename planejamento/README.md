# Guia de entrada para o grupo e suas IAs

Envie à IA o link deste repositório e informe:

> Sou [nome]. Use a branch feat/finalizacao-dashboard-semob como base. Leia AGENTS.md e planejamento/README.md, confira a passagem anterior e execute somente minha etapa do roteiro sequencial. Ao finalizar, prepare a passagem para o próximo integrante e um resumo para a issue da etapa.

Se quiser que a IA também comente no GitHub, acrescente: “Atualize a issue da minha etapa com a passagem, sem segredos ou dados restritos.” A IA precisa ter acesso ao repositório e à API do GitHub para isso; o link sozinho não concede permissões.

| Ordem | Integrante | Entrega | Branch de execução sugerida |
| --- | --- | --- | --- |
| 1 | Guilherme / Gnune2 | Base, dados e acesso MongoDB | feat/01-base-dados |
| 2 | Isabela | Negócio, requisitos e modelos | docs/02-requisitos-modelagem |
| 3 | Gabriel | API e indicadores | feat/03-api-indicadores |
| 4 | Rebecca | Flutter e integração real | feat/04-frontend-real |
| 5 | Larissa | Relatórios, integração e entrega | feat/05-relatorios-entrega |

Leia o [roteiro completo com os cinco prompts](ROTEIRO_SEQUENCIAL_IAS_SEMOB.md). O [plano inicial e inventário de fontes](PLANO_EQUIPE_SEMOB.md) documenta a pesquisa; a execução sequencial prevalece sobre o paralelismo histórico descrito nele.

## Estado atual

Atualização 08/11/2026: o pedido atual autorizou a implementação integrada das cinco etapas sem commits. API, Flutter, relatórios e documentação foram implementados e verificados com base sintética explícita. A leitura real do Atlas, a conciliação de km/viagens e a jornada web/exportação foram concluídas após configuração pelo usuário. Consulte PASSAGEM.md e RESULTADOS_TESTES.md; não trate os registros antigos de planejamento como descrição do código atual.

## Passagem e issues

- [Passagem atual](PASSAGEM.md).
- [Modelo de registro por etapa](passagens/MODELO.md).
- Os corpos de uma issue central e cinco issues de etapa estão em [issues/](issues/). Cada issue aponta para o roteiro, critérios e registro versionado.
- `issues/REGISTRO.json`, quando existir, contém os números e URLs cuja criação foi confirmada pela API. Os arquivos Markdown isolados são propostas de issues, não comprovantes de publicação.
- Para criar/atualizar as seis issues após configurar acesso ao GitHub, execute na raiz `python3 planejamento/issues/publicar_issues.py`. O script utiliza `gh`, preserva os títulos como identificadores e reaproveita issues existentes com o mesmo título. Examine os corpos antes de executar. Não fecha issues nem faz merge.
- A primeira publicação das issues precisa de autorização de escrita e acesso a `api.github.com`; Git HTTPS funcionando não comprova acesso à API. Se o acesso for negado, preserve os arquivos e informe o bloqueio, sem contornar a política de rede.

As etapas avançam após revisão e integração da entrega anterior na base comum. Uma issue aberta não representa tarefa iniciada ou finalizada.
