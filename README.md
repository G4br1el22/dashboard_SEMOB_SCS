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

* **Front-end / Dashboard:** 
* **Back-end / Tratamento de Dados:** 
* **Banco de Dados:** MongoDB

---

##Organização de Pastas

dashboard-operacao-transporte/
├── docs/                     # Documentação do projeto
│   ├── mockup/               # Imagens e protótipos das telas
│   └── relatorios/           # Encarte da disciplina / TTI206
├── src/                      # Código-fonte principal
│   ├── data/                 # Scripts de ingestão e limpeza (Smart Data)
│   ├── components/           # Componentes visuais do painel
│   └── views/                # Visões (Diária, Semestral, Mensal)
├── tests/                    # Testes automatizados de dados e rotas
├── .gitignore                # Arquivos ignorados pelo Git
├── README.md                 # Documentação oficial do repositório
└── requirements.txt          # Dependências do projeto (ou package.json)
