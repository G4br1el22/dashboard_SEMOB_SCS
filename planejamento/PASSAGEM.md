# Snapshot temporario completo

O pedido atual autoriza publicar todo o codigo sanitizado em uma branch temporaria apagavel, sem merge em master. Acrescentado RODAR_SEMOB.bat para preparar dependencias e iniciar a aplicacao. As branches da equipe e seus manifestos permanecem independentes. Base de entrada: 43101de49066f5dc1ead4732e013196204aac607. Os SHAs resultantes sao informados no registro de publicacao, sem criar uma cadeia de commits para registrar o proprio SHA.

# Passagem da versao compartilhavel

Base: 43101de49066f5dc1ead4732e013196204aac607. Pacotes por modulo, com arquivos distintos. Guilherme: dados/configuracao; Isabela: requisitos/modelos; Gabriel: API/calculos; Rebecca: frontend; Larissa: relatorios/validacao/entrega.

Implementacao preparada com assistencia de IA na sessao de Guilherme. Os integrantes devem revisar os patches e publicar com a propria conta, preservando autoria das mudancas anteriores. Os commits registram revisao/publicacao, sem simular datas ou desenvolvimento individual que nao ocorreu.

Os modulos possuem dependencias: somente a integracao das cinco partes deve ser tratada como produto executavel completo. Verificar o manifesto e executar testes/build antes do merge. Dados reais, credenciais, logs, builds e relatorios ficam fora dos pacotes.
