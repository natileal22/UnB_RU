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
* **Arquivos:** `Admin::RestaurantesController`, `Admin::CatracasController`, `GestaoAdministrativa`, `Admin::ExportacoesController`, `ExtratosController`, `Operador::HistoricoController`, `Catraca`, `Restaurant`, `ExportacaoRelatorio`, `GeradorPdf`, `PeriodoFiltro`, `HistoricoLocal`, `ExtratoHistorico`, os helpers dessas telas e, na pasta `app/salvaguarda`, `CardapioApi::Cliente`, `CardapioDoDia` e `InicioController`. Também a tarefa `demo:popular` e o layout `estudante` e `administracao`.

O relatório completo, com o antes, o depois e o porquê de cada mudança, está em `etapa3_entregas/SPRINT3_KASSIO.md`.

**O que foi refatorado**

| Método | Problema | Refatoração |
|---|---|---|
| `CardapioApi::Cliente` (6 métodos com flog entre 21,2 e 27,4) | O arquivo misturava falar com a API e importar o cardápio para o banco. O importador não era chamado por nenhum código, e o `.env` era lido linha a linha na mão. Nota C, 13 cheiros e 34,5% de cobertura. | Removi o importador (código morto) e passei a ler o `.env` com `Dotenv.parse`, que já vem na gem `dotenv-rails` do projeto. As falhas e as opções HTTP viraram constantes (`FALHAS`, `OPCOES_HTTP`). Flog do arquivo: 195,4 → 54,2, nota C → B. |
| `GeradorPdf#montar` e `ExportacaoRelatorio#gerar` | Flog 19,8 e 16,0. `ExportacaoRelatorio` repassava `inicio` e `fim` por vários métodos e tinha o próprio `buscar` e `periodo`, que repetiam o `PeriodoFiltro#aplicar`. | `ExportacaoRelatorio` reaproveita o `PeriodoFiltro#aplicar`, guarda os filtros em um hash (`@filtros`) e usa um único `recusar(erro, status)`. Em `GeradorPdf` extraí `numerar` e a constante `CABECALHO`. Flog: 13,1 e 11,4. |
| `CardapioDoDia#semana` e `InicioController#mostrar_carteira` | Flog 19,4 e 15,3. Conversão de data repetida, intervalo da semana feito à mão, consulta ao `Cardapio` duplicada no `InicioController`. | Datas convertidas uma vez, `Time.zone.today.all_week`, e o `InicioController` reaproveita `CardapioDoDia#da_reserva`. O `case` por perfil virou a tabela `DESTINOS`. Flog: 11,3 e 12,5. |
| `Admin::RestaurantesController` e `Admin::CatracasController` | Os dois repetiam o mesmo fluxo de salvar, bloquear a remoção e remover, e o mesmo `index` e `new`. Nota C nos dois. | O fluxo foi para o concern `GestaoAdministrativa` (`salvar` e `remover`), e cada ação ficou com uma linha. Nota C → A nos dois. Flog dos três arquivos juntos: 93,0 → 77,2. |
| `DadosDemo` (tarefa `demo:popular`) | Os dados estavam dentro de métodos Ruby, e cinco métodos `popular_*` eram quase iguais (flog até 18,7). | Os dados foram para `lib/tasks/demo.yml` e a tarefa ficou com métodos genéricos. Nenhum método passa de 12,0. |
| Layouts `estudante` e `administracao` | Chamavam rotas e um menu que só existem na pasta `app/salvaguarda`. Sem ela, 119 de 162 cenários do Cucumber falhavam. | O layout do estudante usa rotas dos colegas e o do administrador protege a chamada do menu. Sem a `salvaguarda`, os 159 cenários implementados passam. |
| Todas as classes e métodos | Falta de documentação (cheiro *IrresponsibleModule*). | Comentário RDoc nos métodos, com descrição, argumentos, retorno e efeito colateral. |

As features do Cucumber **não foram alteradas** e continuam passando (159 cenários, 3 `undefined` que são da #11, de outro integrante).

**Antes e depois**

| Métrica | Antes | Depois |
|---|---:|---:|
| Maior ABC por método (RuboCop) | 15,81 | **12,41** |
| Maior flog por método (RubyCritic) | 27,4 | **14,3** |
| Métodos com flog ≥ 20 | 6 | **0** |
| Cobertura dos arquivos | 86,2%, 86,5% e 34,5% nos três piores | **100% em todos** |
| RDoc | só em parte | **todos os métodos dos arquivos acima** |

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
