# Sprint 3 — Kassio Gandara de Souza (180140540)

Funcionalidades: **Extrato e Histórico** (#3), **Histórico Local da Catraca** (#7), **Gestão de Restaurantes e Catracas** (#8) e **Exportação em PDF do Relatório de Operação** (#12). Também entram o cliente da API do cardápio e a página inicial da pasta `app/salvaguarda` e a tarefa de dados de demonstração, que também são código meu.

Este arquivo mostra cada refatoração com **o antes, o depois e o porquê**. Os números foram medidos com `flog` (o mesmo cálculo de complexidade do RubyCritic), RubyCritic e SimpleCov, sobre a `main` de 25/11/2026 e sobre a branch `feat/sprint3-kassio`.

## 1. Resumo

| Métrica (nos 25 arquivos que mexi) | Antes | Depois |
|---|---:|---:|
| Métodos com flog ≥ 20 (critério do PDF: < 20) | 6 | **0** |
| Métodos com flog ≥ 15 (perto do limite) | 15 | **0** |
| Maior flog de um método | 27,4 | **14,3** |
| Flog médio por método | 7,3 | **6,2** |
| Flog total dos arquivos | 1062,9 | **812,7** (-24%) |
| Arquivos com nota C no RubyCritic (projeto todo) | 3 | **0** |
| Nota geral do RubyCritic (projeto todo) | 91,1 | **93,4** |
| Exemplos do RSpec | 268 | **313** (0 falhas) |
| Cobertura geral do SimpleCov | 89,5% | **96,6%** |
| Cenários do Cucumber passando | 159 de 162 | **159 de 162** (os 3 restantes são da #11, de outro integrante) |

## 2. O que foi refatorado, o antes, o depois e o porquê

### 2.1 `CardapioApi::Cliente` (cliente da API do cardápio)

**Antes:** um arquivo de 195 de flog (nota C, 13 cheiros do RubyCritic, 34,5% de cobertura). Seis métodos reprovavam o critério (`ler_arquivo_env` 27,4; `salvar_refeicao` 22,4; `para_cardapio_json` 22,3; `carregar_env` 22,0; `executar_get` 21,8; `buscar` 21,2) e `ajustar_bloco` ficava perto (17,9).

**O que causava isso:** o arquivo misturava duas responsabilidades, falar com a API e importar o cardápio para o banco. O importador (`importar_semana_vigente!`, `importar_dia`, `salvar_refeicao`, `para_cardapio_json`, `ajustar_bloco`, `proxima_semana`, `completo`) **não era chamado por nenhum código do projeto**, só aparecia descrito no `LEIA-ME.md`. Além disso, o arquivo `.env` era lido linha a linha na mão, e as tabelas de campos estavam repetidas.

**Depois:** o cliente só faz o que o projeto usa, `semana_vigente`, em poucos métodos pequenos (`buscar`, `ler`, `uri_de`, `chave_de_acesso`, `variavel`). O código morto do importador saiu. A leitura do `.env` usa `Dotenv.parse`, que já vem na gem `dotenv-rails` do Gemfile (sem gem nova), e só roda quando a gem está carregada, então em produção as variáveis vêm direto do ambiente, como antes. As falhas de rede e de status viram uma lista única (`FALHAS`) e uma constante de opções HTTP (`OPCOES_HTTP`), e as tabelas de campos viraram uma só (`CAMPOS`).

| Método | Flog antes | Flog depois |
|---|---:|---:|
| `CardapioApi::Cliente::ler_arquivo_env` | 27,4 | removido |
| `CardapioApi::Cliente::salvar_refeicao` | 22,4 | removido |
| `CardapioApi::Cliente::para_cardapio_json` | 22,3 | removido |
| `CardapioApi::Cliente::carregar_env` | 22,0 | removido |
| `CardapioApi::Cliente::executar_get` | 21,8 | removido |
| `CardapioApi::Cliente::buscar` | 21,2 | **12,3** |
| `CardapioApi::Cliente::ajustar_bloco` | 17,9 | removido |
| `CardapioApi::Cliente::importar_dia` | 14,8 | removido |
| **Arquivo todo (flog total)** | **195,4** | **54,2** |

Nota do RubyCritic: C → B. Cheiros: 13 → 0.

### 2.2 `GeradorPdf`, `ExportacaoRelatorio` e `PeriodoFiltro` (exportação em PDF, #12)

**Antes:** `GeradorPdf#montar` com 19,8 (quase no limite) e `ExportacaoRelatorio#gerar` com 16,0. Em `ExportacaoRelatorio`, o período e os filtros viajavam como parâmetros soltos (`inicio`, `fim`) por vários métodos, e a classe tinha o próprio `buscar` e o próprio `periodo`, que repetiam o que `PeriodoFiltro#aplicar` já fazia.

**Depois:** `ExportacaoRelatorio` passou a **reaproveitar o `PeriodoFiltro#aplicar`** que já existia, guarda os filtros em um único hash (`@filtros`) e lê as datas do próprio período, em vez de repassar `inicio` e `fim` de método em método. A criação do erro virou um único `recusar(erro, status)`. Em `GeradorPdf`, a montagem de cada objeto numerado foi extraída para `numerar`, e o cabeçalho virou a constante `CABECALHO`.

| Método | Flog antes | Flog depois |
|---|---:|---:|
| `GeradorPdf#montar` | 19,8 | **12,4** |
| `ExportacaoRelatorio#gerar` | 16,0 | **11,4** |
| `ExportacaoRelatorio#cabecalho` | 9,7 | **11,0** |
| `ExportacaoRelatorio#initialize` | 7,2 | **11,8** |

**O que não melhorou, e por quê:** o flog total de `exportacao_relatorio.rb` foi de 93,0 para 95,2 e o de `gerador_pdf.rb` ficou em 72,9. O ganho aqui foi nos **métodos grandes** (nenhum passa de 12,4) e nos cheiros (`exportacao_relatorio.rb`: 11 → 0). Os arquivos ganharam alguns métodos pequenos novos (`linhas`, `numerar`), que somam um pouco.

### 2.3 `CardapioDoDia` e `InicioController` (salvaguarda)

**Antes:** `CardapioDoDia#semana` com 19,4 e `InicioController#mostrar_carteira` com 15,3. A conversão de texto para data (`Date.iso8601`) aparecia em vários pontos, a semana era montada com um intervalo calculado à mão, a lista de erros de rede repetia o que o cliente já traduz em `ErroApi`, e o `InicioController` fazia a própria consulta ao `Cardapio` do dia, duplicando a de `CardapioDoDia`.

**Depois:** as datas são convertidas uma vez, quando o índice da semana é montado, a semana usa `Time.zone.today.all_week`, o `rescue` trata só `ErroApi`, e `InicioController` passou a **reaproveitar `CardapioDoDia#da_reserva`**, em vez de repetir a consulta. O `case` do redirecionamento por perfil virou uma tabela (`DESTINOS`) e `(saldo / preço).floor` virou `saldo.div(preço)`.

| Método | Flog antes | Flog depois |
|---|---:|---:|
| `CardapioDoDia#semana` | 19,4 | **11,3** |
| `CardapioDoDia#da_api` | 14,4 | removido |
| `InicioController#mostrar_carteira` | 15,3 | **11,3** |

### 2.4 `Admin::RestaurantesController`, `Admin::CatracasController` e `GestaoAdministrativa` (gestão, #8)

**Antes:** os dois controllers repetiam o mesmo fluxo em três ações: salvar com a validação da gestão e redirecionar ou mostrar o erro, bloquear a remoção quando há vínculo e remover, e abrir a mesma tela em `index` e `new`. O RubyCritic dava nota **C** aos dois.

**Depois:** o fluxo comum foi para o concern que os dois já usavam, `GestaoAdministrativa`, como `salvar(registro, mensagem)` e `remover(registro, mensagem)`, e o `index`/`new` virou uma ação só (`alias`). Cada ação dos controllers ficou com uma linha, e os dois controllers subiram de nota C para **A**.

| Arquivo | Flog total antes | Flog total depois | Nota antes → depois |
|---|---:|---:|---|
| `controllers/admin/restaurantes_controller.rb` | 39,8 | 25,3 | C → A |
| `controllers/admin/catracas_controller.rb` | 29,9 | 16,5 | C → A |
| `controllers/concerns/gestao_administrativa.rb` | 23,3 | 35,4 | A → A |
| **Os três juntos** | **93,0** | **77,2** | |

O concern engordou porque recebeu o código que estava duplicado, mas a soma dos três arquivos caiu. Repetir o mesmo trecho em dois controllers é o tipo de complexidade que o monitor pediu para olhar, e não só dividir métodos.

### 2.5 `DadosDemo` (tarefa `demo:popular`)

**Antes:** os dados de demonstração estavam escritos dentro de métodos Ruby (`usuarios`, `catracas`, `acessos`, `recargas`...), com cinco métodos `popular_*` quase iguais. Quatro passavam de 15 de flog (`popular_recargas` 18,7; `popular_catracas` 18,6; `popular_acessos` 16,6; `acessos` 15,3).

**Depois:** os dados foram para o arquivo `lib/tasks/demo.yml`, e a tarefa ficou com métodos genéricos (`popular`, `ligar`, `tabela`, `popular_tudo`). Dado e código ficaram separados, e nenhum método passa de 12,0.

### 2.6 Layouts independentes da `salvaguarda`

Não é uma refatoração de complexidade, e sim de **acoplamento**. Os layouts `estudante` e `administracao` (meus) chamavam rotas e um menu que só existem na `salvaguarda`. Num teste sem a pasta, **119 de 162 cenários do Cucumber falhavam**. Agora o layout do estudante usa rotas dos colegas (`cardapio_atual_path` e `operador_sair_path`) e o do administrador protege a chamada do menu, como o layout principal já fazia. Sem a `salvaguarda`, os 159 cenários implementados passam, e restam só os 3 `undefined` da #11, que é do Pedro.

### 2.7 `ExtratosController`, `Operador::HistoricoController` e o concern `ConsultaPorPeriodo` (segunda rodada)

**Antes:** o RubyCritic apontava `DuplicateCode` nos dois controllers (nota B nos dois): o fluxo de ler o período da tela, filtrar e mostrar o resultado era o mesmo trecho escrito duas vezes, um para o extrato do estudante (#3) e outro para o histórico local da catraca (#7).

**Depois:** o trecho comum foi para o concern `ConsultaPorPeriodo`, usado pelos dois. Cada controller ficou só com o que é dele. Os dois subiram de nota B para **A** (custo 2,96 → 0,58 e 2,81 → 0,44), sem cheiros. Foi nessa rodada que a nota geral do projeto foi de 92,73 para 93,40. Na mesma rodada, `ExportacaoRelatorio`, `GeradorPdf`, `CardapioDoDia`, `CardapioApi::Cliente` e `Catraca` ficaram sem os cheiros de chamada repetida e de método que não usa estado, mas continuam com nota B, porque o custo deles vem do tamanho total do arquivo e não de um método isolado.

### 2.8 O que ficou só com documentação

Os métodos abaixo de 15 de flog (por exemplo `HistoricoLocal#call` 14,3, `ExportacoesHelper#datas_do_relatorio` 13,9 e `Catraca#historico_preservado` 12,9) **não foram alterados** além do RDoc. Eles já cumprem o critério, e mexer neles só aumentaria o risco de quebrar os cenários do Cucumber, que não podem mudar.

## 3. Cobertura de testes (SimpleCov)

| Arquivo | Antes | Depois |
|---|---:|---:|
| `controllers/admin/catracas_controller.rb` | 86,2% | 100,0% |
| `controllers/admin/exportacoes_controller.rb` | 100,0% | 100,0% |
| `controllers/admin/restaurantes_controller.rb` | 86,5% | 100,0% |
| `controllers/concerns/consulta_por_periodo.rb` | — | 100,0% |
| `controllers/concerns/gestao_administrativa.rb` | 100,0% | 100,0% |
| `controllers/extratos_controller.rb` | 100,0% | 100,0% |
| `controllers/operador/historico_controller.rb` | 100,0% | 100,0% |
| `models/catraca.rb` | 100,0% | 100,0% |
| `models/restaurant.rb` | 100,0% | 100,0% |
| `salvaguarda/cardapio_api/cliente.rb` | 34,5% | 100,0% |
| `salvaguarda/cardapio_completo_controller.rb` | 100,0% | 100,0% |
| `salvaguarda/cardapio_do_dia.rb` | 100,0% | 100,0% |
| `salvaguarda/inicio_controller.rb` | 100,0% | 100,0% |

Pelo PDF, a cobertura de cada controller e model do grupo precisa passar de 90%. Foram escritos testes de **caminho feliz e de caminho triste** (por exemplo, falha de rede, chave ausente e resposta com status de erro no cliente da API, remoção bloqueada e validação inválida na gestão).

## 4. Documentação (RDoc)

Todo método dos arquivos desta lista recebeu um comentário RDoc de quatro partes: o que faz, os argumentos, o retorno (e suas variações) e o efeito colateral (redireciona, grava no banco, faz requisição).

## 5. Como reproduzir

```bash
bundle exec rubycritic --no-browser --format console app lib
bundle exec flog -a -m app lib
bundle exec rspec        # relatório em coverage/index.html
bundle exec cucumber
bundle exec rdoc --output tmp/rdoc app
```

As features do Cucumber **não foram alteradas**.
