# 📊 Dashboard de Operação de Transporte (TTI206)

> Painel interativo para monitoramento operacional e financeiro do sistema de transporte público local, desenvolvido no âmbito do **Projeto Integrador Interdisciplinar (TTI206 - 2026/2)**.

---

## 🎯 Sobre o Projeto

O objetivo do projeto é substituir o envio manual de relatórios estáticos por e-mail por uma **plataforma interativa de inteligência de dados**, permitindo acompanhar a operação em tempo real nas visões **Diária, Semanal e Mensal**.

### 💡 Benefícios
* **Gestão Facilitada:** Visão consolidada da operação de transporte em uma única interface.
* **Detecção de Anomalias:** Identificação ágil de desvios operacionais e financeiros.
* **Apresentação Executiva:** Dados estruturados para relatórios diretos ao Secretário e Prefeito.

---

## 📈 Indicadores Monitorados (KPIs)

* **Quilometragem executada**
* **Total de viagens realizadas**
* **Volume de passageiros pagantes**
* **Volume de passageiros não pagantes (Gratuidades/Isenções)**
* **Métricas financeiras consolidadas**

---

## ⚡ Principal Desafio & Integração

O foco técnico do projeto está na **automação e consumo de dados brutos** do sistema da empresa consolidadora (**Smart Data**), eliminando o fluxo legados de relatórios anexados em e-mails.

---

## 🛠️ Tecnologias Utilizadas

* **Front-end / Dashboard: Dart** 
* **Back-end / Tratamento de Dados: Python** 
* **Banco de Dados:** MongoDB

---

## Integrantes
|Alunos                               | R.A          | Github              |Cargo                              |
|-------------------------------------|--------------|---------------------|-----------------------------------|
| Isabela Simodo Nakai                     | 25.11733-4   | @N4k4i     | Dev. e Documentação               |
| Rebecca Miki Uema               | 25.01550-4   | @rebeccauema       | Dev. e Documentação               |
| Gabriel Medeiros Araujo             | 25.11742-5   | @G4br1el22          | Dev. e Documentação               |
| Larissa Barbosa Oliveira                | 25.11765-6   | @larringe              | Dev. e Documentação               |
| Guilherme Nunes Furtado          | 25.00014-2   | @Gnune2             | Dev. e Documentação               |


```text

##Arquitetura do repositório
/dashboard-operacao-transporte
│
├── .gitignore                  # Arquivos ignorados pelo git (node_modules, .env, build/)
├── README.md                   # Documentação principal do repositório
│
├── /backend                    # API em Python (FastAPI/Flask) e Integração MongoDB
│   ├── requirements.txt        # Dependências (fastapi, uvicorn, pymongo, pandas)
│   ├── main.py                 # Ponto de entrada da API
│   ├── /config
│   │   └── database.py         # Conexão com o MongoDB (PyMongo ou Motor)
│   ├── /models
│   │   └── schemas.py          # Estruturas de dados esperadas/validadas (Pydantic se usar FastAPI)
│   ├── /routes
│   │   ├── kpis.py             # Rota para os 6 cartões superiores (Quilometragem, Viagens, Receita, etc.)
│   │   ├── graficos.py         # Rota para alimentar o gráfico de barras (Demanda) e rosca (Composição)
│   │   └── filtros.py          # Rota para lidar com a alternância "Diária / Semanal / Mensal"
│   └── /services
│       └── smart_data_sync.py  # Lógica para puxar e tratar os dados brutos para inserir no MongoDB
│
└── /frontend                   # Aplicação Flutter / Dart
    ├── pubspec.yaml            # Dependências (http/dio, fl_chart, provider/riverpod)
    ├── /lib
    │   ├── main.dart           # Ponto de entrada do app Flutter
    │   ├── /core
    │   │   ├── theme.dart      # Definição do tema escuro (Dark Mode) visto no mockup
    │   │   └── api_client.dart # Configuração do cliente HTTP para conectar com o Python
    │   ├── /models
    │   │   ├── kpi_model.dart  # Molde para os dados dos cartões (valor atual e variação percentual)
    │   │   └── chart_data.dart # Molde para os eixos X e Y dos gráficos
    │   ├── /screens
    │   │   ├── layout_base.dart       # Estrutura principal contendo a Sidebar e a Topbar
    │   │   ├── visao_geral.dart       # A tela mostrada na 'image 2.png'
    │   │   ├── frota_viagens.dart     # (Demais telas baseadas no menu lateral)
    │   │   ├── passageiros.dart
    │   │   ├── financeiro.dart
    │   │   ├── linhas.dart
    │   │   ├── anomalias.dart
    │   │   └── relatorios.dart
    │   └── /widgets
    │       ├── sidebar_menu.dart      # Menu lateral de navegação
    │       ├── top_header.dart        # Barra superior com botões de filtro temporal, busca e exportação
    │       ├── kpi_card.dart          # Componente reutilizável para os 6 blocos de indicadores
    │       ├── bar_chart_demanda.dart # Componente do gráfico de barras empilhadas (Demanda de passageiros)
    │       └── donut_chart_comp.dart  # Componente do gráfico de rosca (Composição de demanda)
    └── /assets
        ├── /icons              # Ícones customizados da sidebar e dos cards
        └── /fonts              # Fontes específicas utilizadas no design


'''
