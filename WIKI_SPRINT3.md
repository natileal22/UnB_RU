# Wiki - Sprint 3

**Grupo:** 08

**Sprint Entregue:** Sprint 3 — Refatoração e Documentação (ESaaS, Capítulo 9)

**Integrantes:**

* Natália Leal - 221021581
* Pedro de Paula - 231036050
* Kassio Gandara de Souza - 180140540
* Isabela de Souza - 190088931
* Adriano Lopes - 170097960

---

## 1. Papéis da Equipe
* **Scrum Master:** Isabela de Souza
* **Product Owner (PO):** Adriano Lopes

## 2. Critérios da Sprint e ferramentas

| Critério | Meta | Ferramenta |
|---|---|---|
| Complexidade dos métodos | ABC Score < 20 por método | RubyCritic (Flog e Reek) |
| Cobertura de testes | > 90% em cada controller e model do grupo | SimpleCov |
| Caminhos de teste | Happy Path e Sad Path em todas as features | RSpec e Cucumber (features não alteradas) |
| Documentação | Todos os métodos documentados | RDoc |

Como reproduzir as análises:

```bash
bundle exec rspec                 # testes + cobertura em coverage/index.html
bundle exec cucumber              # testes de aceitação
bundle exec rubycritic --no-browser --format console app
bundle exec rdoc --output tmp/rdoc app
```

## 3. Resultado geral do projeto

> Preencher no fim, depois que todos os PRs da Sprint 3 entrarem no `main`.

| Métrica | Antes da Sprint 3 | Depois da Sprint 3 |
|---|---:|---:|
| Cobertura total (SimpleCov) | 89,21% | |
| Score do RubyCritic | | |
| Cenários do Cucumber passando | 159 de 162 | |
| Exemplos do RSpec | 265 | |

---

## 4. Refatoração por funcionalidade

> **Como cada integrante preenche:** copie o modelo da sua seção, troque os `...` pelos seus números e
> apague o que não se aplicar. Edite **só a sua seção**, para não dar conflito com os colegas.

### 4.1 Recarga de Saldo e Cardápio da Refeição Atual
* **Responsável:** Natália Leal
* **Arquivos:** `RecargasController`, `CardapiosController`, `Recarga`, `Cardapio`, `ItemCardapio`, `GatewayCartao`, `HorarioRefeicao`, `lib/tasks/cardapio.rake`

**O que foi refatorado**

| Método | Problema | Refatoração |
|---|---|---|
| `RecargasController#processar_cartao` | Método mais complexo (ABC 14,35) e smell *TooManyStatements*: validava, gravava, cobrava e redirecionava. | Extraídos `dados_cartao` e `cobrar_cartao`. |
| `RecargasController#create` | `if/else` só para escolher PIX ou cartão. | Trocado por operador ternário. |
| `GatewayCartao.dados_validos?` | Quatro regras em uma expressão e smell *LongParameterList*. | Recebe um `Hash` e cada regra virou um método privado. |
| `HorarioRefeicao.atual` e `.proxima` | Conversão de horário repetida. | Extraído `hora_de`. |
| Todas as classes | Smell *IrresponsibleModule* (sem documentação). | RDoc em classes e constantes. |

**Correção de regra de negócio (RN07):** um funcionário logado conseguia fazer recarga. Agora recebe 403 ("esta página é exclusiva do estudante"), com 2 testes novos de caminho triste.

**Antes e depois**

| Métrica | Antes | Depois |
|---|---:|---:|
| Maior ABC por método | 14,35 | 12,21 |
| ABC de `processar_cartao` | 14,35 | 7,14 |
| Smells do RubyCritic (Reek) | 12 | 4 |
| Cobertura dos 7 arquivos | 100% | 100% |
| RDoc (classes, constantes e métodos) | 21,21% | 100% |
| Cenários do Cucumber da funcionalidade | 7 passando | 7 passando (features não alteradas) |

Os 4 smells restantes são convenções do Rails: *InstanceVariableAssumption* (controllers passam dados à view por
`@variavel`) e *MissingSafeMethod* (`aprovar!` e `recusar!` usam `!` porque alteram o banco e lançam erro se falharem).

Relatório completo: `etapa3_entregas/SPRINT3_NATALIA.md`.

* **Declaração de Uso de IA:** Foi utilizada IA generativa, Claude (Anthropic), pelo Claude Code, na Sprint 3. A IA mediu o código com RubyCritic, SimpleCov, RuboCop e RDoc, propôs e aplicou as refatorações, escreveu os comentários RDoc, corrigiu a RN07 e criou os testes novos. Eu revisei as mudanças, rodei os testes no meu computador e validei os resultados antes de abrir o PR.

---

### 4.2 Autenticação do Funcionário
* **Responsável:** Pedro de Paula
* **Arquivos:** ...

**O que foi refatorado**

| Método | Problema | Refatoração |
|---|---|---|
| ... | ... | ... |

**Antes e depois**

| Métrica | Antes | Depois |
|---|---:|---:|
| Maior ABC por método | ... | ... |
| Cobertura dos arquivos | ... | ... |
| RDoc | ... | ... |

* **Declaração de Uso de IA:** ...

---

### 4.3 Validação de Entrada e Configuração do Ponto de Acesso
* **Responsável:** Isabela de Souza
* **Arquivos:** ...

**O que foi refatorado**

| Método | Problema | Refatoração |
|---|---|---|
| ... | ... | ... |

**Antes e depois**

| Métrica | Antes | Depois |
|---|---:|---:|
| Maior ABC por método | ... | ... |
| Cobertura dos arquivos | ... | ... |
| RDoc | ... | ... |

* **Declaração de Uso de IA:** ...

---

### 4.4 Extrato e Histórico, Histórico Local, Gestão de Restaurantes e Catracas, Exportação em PDF
* **Responsável:** Kassio Gandara de Souza
* **Arquivos:** ...

**O que foi refatorado**

| Método | Problema | Refatoração |
|---|---|---|
| ... | ... | ... |

**Antes e depois**

| Métrica | Antes | Depois |
|---|---:|---:|
| Maior ABC por método | ... | ... |
| Cobertura dos arquivos | ... | ... |
| RDoc | ... | ... |

* **Declaração de Uso de IA:** ...

---

### 4.5 Cadastro de Usuário e Relatório Global de Acessos
* **Responsável:** Adriano Lopes
* **Arquivos:** ...

**O que foi refatorado**

| Método | Problema | Refatoração |
|---|---|---|
| ... | ... | ... |

**Antes e depois**

| Métrica | Antes | Depois |
|---|---:|---:|
| Maior ABC por método | ... | ... |
| Cobertura dos arquivos | ... | ... |
| RDoc | ... | ... |

* **Declaração de Uso de IA:** ...
