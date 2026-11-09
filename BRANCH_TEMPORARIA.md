# Snapshot temporario do projeto completo

Esta branch contem o projeto completo sanitizado, preparado com assistencia de IA a pedido de Guilherme. E independente das branches de publicacao dos integrantes e nao deve ser usada para substituir suas entregas.

Branch: temporaria/projeto-completo-20261108-3eef946c. Base: 43101de49066f5dc1ead4732e013196204aac607. Nao houve merge na master nem alteracao das outras branches.

Pode ser removida pelo responsavel no GitHub depois de usar. Apagar esta referencia nao apaga a master, as branches da equipe ou a copia funcional local. Nao existe exclusao agendada ou automatica. Nao fazer merge deste snapshot se o objetivo e manter apenas a integracao revisada das partes da equipe.

## Executar no Windows

Baixe ou clone a branch inteira, extraia se necessario e abra RODAR_SEMOB.bat. O BAT procura Git e Python 3.13, instala-os via WinGet se faltarem, prepara dependencias Python, Flutter 3.47.9, analisa, testa, gera o build web e abre a aplicacao.

A primeira execucao requer internet e pode solicitar interacao com instaladores. Se WinGet nao estiver disponivel, o script informa os links oficiais para instalacao manual. Nao altera verificacoes TLS nem configuracoes de seguranca do Windows. Um marcador local permite reutilizar o ambiente nas proximas aberturas; mudancas nos arquivos relevantes provocam nova preparacao.

Sem configuracao de banco, abre demonstracao identificada. Com configuracao propria, usa MongoDB. Para cadastrar o banco, execute Configurar MongoDB.cmd; nenhuma credencial e distribuida neste snapshot.

Opcoes: RODAR_SEMOB.bat -Demo, -Real, -Reinstalar, -PrepararSomente, -NoBrowser e -SemInstalarSistema. A opcao -Real abre o configurador se ainda nao houver conexao. Use Parar SEMOB.cmd para encerrar os servidores do projeto.

Fontes oficiais: https://learn.microsoft.com/windows/package-manager/winget/install e https://docs.python.org/3.13/using/windows.html . Os scripts nao incluem .env real, dados operacionais, credenciais ou arquivos gerados.
