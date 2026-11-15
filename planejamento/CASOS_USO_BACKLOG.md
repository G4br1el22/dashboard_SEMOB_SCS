# Casos de uso e backlog de homologação

| Caso | Fluxo principal | Alternativas |
| --- | --- | --- |
| UC01 Consultar operação | Abrir painel, selecionar período e linha, visualizar totais e cobertura | Fonte indisponível: mensagem e tentar novamente; intervalo vazio: informar ausência; data inválida: 422 |
| UC02 Comparar períodos | Selecionar comparação, consultar janelas equivalentes, mostrar variação | Base zero, incompleta ou ausente: omitir percentual |
| UC03 Exportar consulta | Escolher filtros em Relatórios, gerar PDF/XLSX e baixar | Sem dados: rejeitar geração; ID inexistente: 404; falha de fonte: 503 |
| UC04 Configurar conexão | Executar configurador, inserir URI oculta, validar leitura, salvar configuração | Acesso negado/rede: não salvar; corrigir credencial ou allowlist |

Cenários de aceitação:
- Dada uma tabela diária e uma por linha cobrindo o mesmo dia, quando consultada quilometragem geral, então usar a família diária uma única vez.
- Dado custo sem origem validada, quando aberto Financeiro, então apresentar indisponibilidade e não mostrar superávit.
- Dada consulta apenas da linha 101, quando passageiros existem somente em total municipal, então manter passageiros da linha indisponíveis.
- Dado Mongo não configurado, quando aberta a aplicação real, então responder 503 sem trocar para demo.
- Dado relatório gerado, quando reiniciado o serviço, então manter sua listagem e download locais.

Próximo backlog: conectar Atlas, confirmar esquema, conciliar totais, validar regras com a SEMOB, obter rubrica e revisar o relatório acadêmico com o grupo. Autenticação/publicação só entram após definição de ambiente e necessidade.
