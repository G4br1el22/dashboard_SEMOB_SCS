# Processo atual e processo proposto

Segundo o README, a equipe recebe relatórios estáticos da consolidadora e precisa consolidá-los para análise. Frequência, responsáveis pelo envio e aprovações efetivas permanecem sem nova validação com a SEMOB.

O processo implementado começa com dados já carregados no MongoDB: analista abre aplicação local, seleciona período/linha, API consulta a view preferencial, aplica regras e devolve indicadores com cobertura. O analista pode gerar PDF ou XLSX com os mesmos filtros e baixar um arquivo persistido localmente. Falha da fonte resulta em mensagem e nova tentativa; ausência de registros impede exportação de sucesso sem conteúdo.

O importador existente permanece uma ferramenta separada e manual. A aplicação não entra no Smart Data nem atualiza o Atlas automaticamente. Gerar relatório não envia e-mail.

O fluxo editável em modelos/arquitetura.mmd representa a execução e as fronteiras. Não é apresentado como BPMN homologado: não foi inventado um processo operacional detalhado sem entrevistas. Para a revisão do grupo, recomenda-se validar responsáveis e eventos antes de produzir um BPMN definitivo.
