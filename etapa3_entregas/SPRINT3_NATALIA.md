# Sprint 3 — Natália Leal (221021581)

Funcionalidades: **Recarga de Saldo** (issue #2) e **Cardápio da Refeição Atual**.

Arquivos analisados: `RecargasController`, `CardapiosController`, `Recarga`, `Cardapio`, `ItemCardapio`,
`GatewayCartao`, `HorarioRefeicao` e a tarefa `cardapio:importar`.

## 1. O que foi refatorado

| Método | Problema encontrado | Refatoração aplicada |
|---|---|---|
| `RecargasController#processar_cartao` | Método mais complexo da funcionalidade (ABC 14,35; Flog 16,7) e smell *TooManyStatements* do Reek: validava, gravava, cobrava e redirecionava. | Extraí `dados_cartao` (monta os dados do formulário) e `cobrar_cartao` (pede a autorização e aprova ou recusa). `processar_cartao` passou a só validar, gravar e delegar. |
| `RecargasController#create` | `if/else` de 5 linhas só para escolher entre PIX e cartão. | Troquei por um operador ternário: `@recarga.pix? ? criar_pix : processar_cartao`. |
| `GatewayCartao.dados_validos?` | Quatro regras de formato em uma expressão só (Flog 14,1) e smell *LongParameterList* (4 parâmetros). | O método recebe um único `Hash` e cada regra virou um método privado com nome (`numero_valido?`, `validade_valida?`, `cvv_valido?`, `somente_digitos`). A limpeza dos espaços do número, que estava repetida em dois métodos, ficou em um lugar só. |
| `HorarioRefeicao.atual` e `.proxima` | A conversão `agora.strftime('%H:%M')` estava repetida. | Extraí o método privado `hora_de`. |
| Todas as classes | Smell *IrresponsibleModule* (classe sem documentação) em 6 classes. | Comentário RDoc no topo de cada classe e constante. |

**Correção de regra de negócio (RN07):** o filtro `exigir_estudante` só verificava se havia alguém logado, então um
funcionário conseguia fazer recarga. Agora ele recebe 403 com a mensagem "esta página é exclusiva do estudante", a
mesma do extrato. Foram criados dois testes de caminho triste para isso em `spec/requests/recargas_spec.rb`.

As features do Cucumber (`recarga_saldo.feature` e `cardapio-atual.feature`) **não foram alteradas** e continuam
passando (7 cenários, 7 passaram).

## 2. Antes e depois

### ABC Score por método (os maiores)

Medido com o RuboCop (`Metrics/AbcSize`). A nota de complexidade do RubyCritic vem do Flog, que também aparece na tabela.

| Método | ABC antes | ABC depois | Flog antes | Flog depois |
|---|---:|---:|---:|---:|
| `RecargasController#processar_cartao` | 14,35 | **7,14** | 16,7 | **6,5** |
| `RecargasController#create` | 12,41 | **12,21** | 14,8 | 14,8 |
| `GatewayCartao.dados_validos?` | 10,44 | **8,60** | 14,1 | **10,7** |
| `RecargasController#cobrar_cartao` (novo) | — | 8,25 | — | 10,0 |
| `RecargasController#dados_cartao` (novo) | — | 7,07 | — | 8,1 |
| Média Flog por método (todos os arquivos) | | | 7,0 | **5,8** |

Nenhum método fica perto de 20, nem antes nem depois.

### RubyCritic (por arquivo)

| Arquivo | Nota antes | Nota depois | Smells antes | Smells depois |
|---|:---:|:---:|---:|---:|
| `recargas_controller.rb` | B | B | 3 | 1 |
| `cardapios_controller.rb` | A | A | 2 | 1 |
| `recarga.rb` | A | A | 3 | 2 |
| `cardapio.rb` | A | A | 1 | 0 |
| `item_cardapio.rb` | A | A | 1 | 0 |
| `gateway_cartao.rb` | A | A | 1 | 0 |
| `horario_refeicao.rb` | A | A | 1 | 0 |
| **Total** | | | **12** | **4** |

Os smells que sobraram são convenções do Rails, não problemas do código:
- *InstanceVariableAssumption* (controllers): as actions usam variáveis de instância (`@recarga`, `@refeicao`) para
  passar dados à view, que é o padrão do Rails.
- *MissingSafeMethod* (`aprovar!`, `recusar!`): o Reek pede uma versão sem `!`. No Rails o `!` indica que o método
  altera o banco e lança erro se falhar, e uma versão "segura" não teria uso aqui.

O `recargas_controller.rb` continua com nota B porque a nota é por arquivo: ele tem a maior parte da lógica da
recarga, e a soma do Flog sobe com os métodos extraídos, mesmo com cada método mais simples.

### Cobertura de testes (SimpleCov)

| Arquivo | Antes | Depois |
|---|---:|---:|
| `app/controllers/recargas_controller.rb` | 100% (42/42) | 100% (45/45) |
| `app/controllers/cardapios_controller.rb` | 100% (6/6) | 100% (6/6) |
| `app/models/recarga.rb` | 100% (12/12) | 100% (12/12) |
| `app/models/cardapio.rb` | 100% (7/7) | 100% (7/7) |
| `app/models/item_cardapio.rb` | 100% (8/8) | 100% (8/8) |
| `app/services/gateway_cartao.rb` | 100% (6/6) | 100% (16/16) |
| `app/services/horario_refeicao.rb` | 100% (11/11) | 100% (14/14) |

Testes novos: 2 de caminho triste para o funcionário na recarga e 2 no `GatewayCartao` (cartão sem número e número
digitado com espaços).

### Documentação (RDoc)

| | Antes | Depois |
|---|---:|---:|
| Classes documentadas | 2 de 7 | 7 de 7 |
| Constantes documentadas | 0 de 4 | 4 de 4 |
| Métodos documentados | 5 de 22 | 28 de 28 |
| **Total** | **21,21%** | **100%** |

Cada método responde às quatro perguntas pedidas: o que faz, quais argumentos recebe, o que retorna (e se há mais
de um retorno possível) e quais efeitos colaterais tem (redirecionamento, render, alteração no banco).

## 3. Como reproduzir

```bash
bundle exec rspec                                   # cobertura em coverage/index.html
bundle exec cucumber features/recarga_saldo.feature features/cardapio-atual.feature
bundle exec rubycritic --no-browser app/controllers/recargas_controller.rb app/controllers/cardapios_controller.rb app/models/recarga.rb app/models/cardapio.rb app/models/item_cardapio.rb app/services/gateway_cartao.rb app/services/horario_refeicao.rb
bundle exec rdoc --all --output tmp/rdoc app/controllers/recargas_controller.rb app/controllers/cardapios_controller.rb app/models/recarga.rb app/models/cardapio.rb app/models/item_cardapio.rb app/services/gateway_cartao.rb app/services/horario_refeicao.rb lib/tasks/cardapio.rake
```

## Declaração de uso de IA

Foi utilizada IA generativa, Claude (Anthropic), pelo Claude Code, na Sprint 3 desta funcionalidade. A IA mediu o
código com RubyCritic, SimpleCov, RuboCop e RDoc, propôs e aplicou as refatorações, escreveu os comentários RDoc,
corrigiu a regra RN07 da recarga e criou os testes novos. Eu revisei as mudanças, rodei os testes e validei os
resultados antes do commit.
