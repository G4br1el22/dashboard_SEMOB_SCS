# Requisitos da implementação local

| ID | Comportamento e critério de aceitação | Origem |
| --- | --- | --- |
| RF01–RF06 | Preservar importação auditável, tipagem e eleição de fonte; cinco testes originais aprovados | Importador existente |
| RF07 | API solicita somente campos operacionais permitidos da view, com registro diário e fonte preferencial | Especificação Drive |
| RF08 | Visão geral responde com indicadores, série diária e linhas no período | Modelos Dart |
| RF09 | Passageiros, frota/viagens, financeiro e linhas consultam as mesmas regras | Modelos Dart |
| RF10 | Dia, 7/15/30 dias, datas inclusivas até 366 dias, linha e segunda a sexta; rejeitar entradas inválidas | Filtros Dart e roteiro |
| RF11 | Listar, gerar e baixar PDF/XLSX; arquivo usa o mesmo período e filtro da consulta | Produto e roteiro |
| RF12 | Exibir fonte, última data disponível, carregamento, erro, nova tentativa e ausência de dados | Especificação Drive |
| RF13 | Demo explícito, sem fallback silencioso de Mongo para números fictícios | Especificação Drive |
| RNF01 | TLS validado no Atlas e servidor HTTP apenas em 127.0.0.1; publicação externa fora do escopo | Execução local |
| RNF02 | URI somente backend/.env ignorado ou ambiente; entrada oculta pelo configurador | Segurança do plano |
| RNF03 | Nenhuma escrita MongoDB pela aplicação; usuário deve ter leitura da view | Plano |
| RNF06 | Cálculos Decimal; JSON decimal string; ausência diferente de zero | Plano e importador |
| RNF07 | Limite de 366 dias, 200.000 registros, timeout 25 s e cache local de 15 s | Decisão de implementação |
| RNF09 | Layout responsivo web e formatação pt-BR | Frontend existente |
| RNF10–RNF12 | Serviços compartilhados, logs locais sem URI, testes e cobertura de lacunas | Plano |

Regras: padrão é o último dia disponível na fonte, sem fingir dados de ontem. Os períodos rápidos são janelas corridas de 1/7/15/30 dias até essa referência. Segunda a sexta não remove feriados. Ano anterior substitui 29/02 por 28/02. Período anterior usa janela contígua de igual duração. Base zero ou cobertura incompleta omitem percentual.

Sem receita/custo não há resultado ou cobertura. Sem cadastro não há manutenção nem idade. Sem definição de pontualidade/ocupação não há status automático. Somatórios de granularidades sobrepostas são proibidos.
