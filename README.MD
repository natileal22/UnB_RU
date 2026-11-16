# UnB RU

---

Sistema de gerenciamento para o Restaurante Universitário da UnB.

## Links do projeto

- [Wiki do repositório](https://github.com/natileal22/UnB_RU/wiki): funcionalidades, regras de negócio e responsáveis.
- [Kanban da Sprint 2](https://github.com/users/Kassio-Souza/projects/3): Backlog, Doing, Done e Accepted.
- [Repositório do grupo](https://github.com/natileal22/UnB_RU).

## Banco de dados

O projeto usa PostgreSQL. Em produção e no desenvolvimento compartilhado ele roda no Supabase; nos testes, sempre em um PostgreSQL local.

### Primeira execução

1. Instale o PostgreSQL e rode `bundle install`.
2. Copie `.env.example` para `.env`. Sem nenhuma conexão remota configurada, o app usa o PostgreSQL local (`localhost:5432`, usuário `postgres`).
3. Crie os bancos com `bin/rails db:create` e confira o ambiente com `bundle exec cucumber -p fumaca`. O comando `bundle exec cucumber` sem perfil roda todas as features e sai com código 1 enquanto houver passos ainda não implementados.

### Usar o Supabase

Descomente `DATABASE_URL` no `.env` e preencha com a string de conexão do projeto (Configurações do projeto > Database). Use a porta 6543 (Supavisor, modo transação) no dia a dia. O app liga `sslmode=require` e desliga `prepared_statements` e `advisory_locks` sozinho nessa porta. O banco de teste ignora essa variável e continua local.

### Como migrar

O modo transação (porta 6543) não serve para migrações. Para rodar `bin/rails db:migrate`:

1. Troque a `DATABASE_URL` do `.env` pela conexão da porta 5432 (pooler em modo sessão ou conexão direta; o `DIRECT_URL` do `.env.example` mostra o formato).
2. Rode `bin/rails db:migrate`.
3. Volte a `DATABASE_URL` para a porta 6543.

Estas tarefas recusam rodar contra servidor remoto: `db:drop`, `db:drop:_unsafe`, `db:reset`, `db:setup`, `db:schema:load`, `db:purge`, `db:purge:all`, `db:migrate:reset`, `db:truncate_all` e `db:seed:replant`. Outras tarefas que alterem o banco não têm essa trava. Se for isso mesmo que você quer, rode com `PERMITIR_BANCO_REMOTO=sim`.

### Chave das credenciais

O `config/credentials.yml.enc` vem no repositório, mas a `config/master.key` não. Peça a chave a quem mantém o projeto.

## Como rodar o projeto

```bash
bundle install
cp .env.example .env          # sem DATABASE_URL, usa o PostgreSQL local
bin/rails db:create db:migrate db:seed
bin/rails server              # http://localhost:3000
```

A seed cria dois estudantes (`123456789` e `202012345`) e um funcionário (`1234567`). O administrador não vem na
seed. Para criar um, abra o `bin/rails console` e rode:

```ruby
User.create!(name: "Administrador", matricula: "7654321", email: "admin@unb.br",
             password: "SenhaCorreta123", perfil: "administrador")
```

A página inicial (`/`) tem os acessos de estudante, operador e administrador. Estudantes entram em `/login`, e
funcionários e administradores em `/operador/entrar`.

### Rodar todos os testes

```bash
bundle exec rspec
bundle exec cucumber --strict --tags "not @wip" $(grep -oE "features/[a-z_-]+\.feature" .github/workflows/ci.yml | sort -u)
bundle exec rubocop --fail-level E
```

O CI do GitHub Actions (`.github/workflows/ci.yml`) roda esses três comandos a cada push.

## Deploy

A aplicação está no ar em **https://unb-ru.onrender.com**. Ela roda no [Render](https://render.com) (plano gratuito) com o banco no [Supabase](https://supabase.com), e o `GET /up` é o health check: responde 200 quando ela está no ar.
No plano gratuito o serviço hiberna depois de 15 minutos sem acesso, então o primeiro acesso depois de um tempo parado leva de 30 a 60 segundos.

Estudantes entram em `/login`, e funcionários e administradores em `/operador/entrar` (o administrador também é funcionário, então a porta de entrada é a mesma).

### Tecnologias

- Ruby 3.3.12 e Rails 8.1, com Puma como servidor.
- Propshaft para os assets, com importmap.
- PostgreSQL gerenciado no Supabase, conectado pelo Session Pooler (IPv4, porta 5432, SSL obrigatório). Os testes usam um PostgreSQL local.
- Hospedagem no Render: web service gratuito, região Oregon, branch `sprint-2`.
- CI e CD no GitHub Actions: o `ci.yml` roda RSpec, Cucumber e RuboCop, e o `cd.yml` dispara o deploy no Render pelo deploy hook quando o CI passa na `main`.
- RSpec e Cucumber com Capybara (rack_test) nos testes, e RuboCop no estilo do código.
- Protótipo das telas no Figma.

### Como o deploy funciona

**Arquivos do deploy**

- `render.yaml`: descreve o serviço web (Ruby, plano gratuito, health check em `/up`), sem nenhum segredo.
- `bin/render-build.sh`: instala as gems, compila os assets, aplica as migrations no banco e importa o cardápio. Só roda a seed se `SEED_DEMO` for `true`.
- `.github/workflows/cd.yml`: o CD. Quando o CI passa na `main`, chama o deploy hook do Render. Também dá para disparar à mão em Actions > CD > Run workflow.

**Variáveis do serviço no Render**

| Variável | Valor |
|---|---|
| `RAILS_ENV` | `production` |
| `RUBY_VERSION` | `3.3.12` |
| `SECRET_KEY_BASE` | gerada pelo Render |
| `DATABASE_URL` | string do Session Pooler do Supabase (Connect > Session pooler, porta 5432) |
| `RU_API_TOKEN` | chave da API do cardápio, preenchida só no painel do Render |
| `RU_API_URL` | endereço da API do cardápio |
| `SEED_DEMO` | `false` (use `true` só no primeiro deploy, se quiser dados de exemplo) |

A senha do banco só entra na `DATABASE_URL`, e a chave do cardápio só na `RU_API_TOKEN`, as duas no painel do Render. Elas nunca vão para o Git.

**Passo a passo**

1. No Render, crie um Web Service a partir do repositório e da branch `sprint-2` (ou um Blueprint com o `render.yaml`).
2. Preencha a `DATABASE_URL` e confirme as outras variáveis da tabela.
3. Em Settings > Deploy Hook, copie a URL e guarde no GitHub como o secret `RENDER_DEPLOY_HOOK_URL`
   (Settings > Secrets and variables > Actions). Depois disso, cada push na `main` com o CI verde publica sozinho.
4. O primeiro deploy cria as tabelas pelo `db:migrate` do script de build.

## Contas de demonstração

Para os monitores e a professora testarem, o site https://unb-ru.onrender.com já está com dados de demonstração. As contas e os dados são fictícios e existem só para a avaliação. O primeiro acesso pode levar de 30 a 60 segundos, porque o plano gratuito do Render hiberna.

| Perfil | Onde entrar | Matrícula | Senha | Observação |
|---|---|---|---|---|
| Estudante | `/login` | `241012345` | `Aluno@2026` | Ana Souza, saldo R$ 18,00 |
| Estudante | `/login` | `241012346` | `Aluno@2026` | Bruno Lima, saldo R$ 9,00 |
| Estudante | `/login` | `241012347` | `Aluno@2026` | Carla Mendes, saldo R$ 0,00: use para ver a recusa por saldo insuficiente |
| Estudante | `/login` | `241012348` | `Aluno@2026` | Diego Alves, saldo R$ 4,50, o valor exato de uma refeição |
| Estudante | `/login` | `241012349` | `Aluno@2026` | Elisa Rocha, saldo R$ 50,00 |
| Funcionário | `/operador/entrar` | `1234567` | `Funcionario@2026` | Maria Fiscal, responsável pelas catracas do RU Darcy Ribeiro |
| Funcionário | `/operador/entrar` | `2345678` | `Funcionario@2026` | João Operador, responsável pela catraca do RU Gama |
| Administrador | `/operador/entrar` | `7654321` | `Admin@2026` | Administrador RU (também é funcionário, então a porta de entrada é a mesma) |

Na tela de login, preencha os campos Matrícula e Senha.

**O que cada perfil vê**

- Estudante: início com a carteira, recarga, cardápio e extrato.
- Funcionário e administrador: ponto de acesso, operação, histórico local e gestão de restaurantes e catracas.

**Dados de exemplo carregados**

- 3 restaurantes, sendo um inativo.
- 5 catracas, em status variados.
- 12 acessos, liberados e negados.
- 6 recargas, em PIX e cartão, com status variados.
- O cardápio da semana.

As senhas de demonstração ficam no código de propósito e só valem para esta demonstração.

## Funcionalidades da Sprint 2

### Cadastro de usuário

Acesse `GET /cadastro/new` para cadastrar um estudante com nome, matrícula e senha.
A matrícula deve ter nove dígitos e não pode estar cadastrada anteriormente. O cadastro
persiste o registro em `users` e redireciona para `/login` com a mensagem de sucesso.
Não há autenticação real nesta entrega e a senha é persistida conforme a especificação
da sprint, sem criptografia.

### Relatório global de operação

Administradores acessam `GET /admin/relatorio`. A tela lista os acessos registrados e
permite filtrar por restaurante, catraca, resultado e período. A opção de agrupamento
consolida a quantidade por restaurante e catraca. Quando nenhum registro corresponde
aos filtros, a tela exibe uma mensagem de lista vazia.

### Validação de entrada

Acesse `GET /catracas/:id` (a tela de uma catraca) e informe a matrícula do estudante.
O sistema verifica, nesta ordem, o formato da matrícula (nove dígitos), se a catraca e o
restaurante estão ativos, se a catraca pertence ao restaurante selecionado pelo
funcionário (quando houver ponto de acesso configurado), se o estudante está cadastrado
e se o saldo cobre a refeição de R$ 4,50. Com tudo válido, a entrada é liberada e o
valor é debitado do saldo; caso contrário, a tela mostra o motivo da recusa e o saldo não
muda. Toda tentativa, liberada ou negada, é registrada em `accesses` com o resultado, o
motivo da negação e o valor cobrado, e aparece no relatório global de operação. A regra
fica em `app/services/validacao_entrada.rb`, e o débito e o registro acontecem na mesma
transação.

### Configuração do ponto de acesso

Funcionários e administradores entram por `GET /operador/entrar` e escolhem em
`GET /ponto-de-acesso` o restaurante em que vão operar. A lista mostra apenas
restaurantes ativos. A escolha fica guardada na sessão e leva à tela de operação
(`GET /operacao`), que exibe o restaurante e suas catracas. Estudantes recebem a mensagem
de acesso negado, e quem não está autenticado é redirecionado para a autenticação do
operador. Com o ponto de acesso configurado, a validação de entrada só aceita catracas do
restaurante selecionado.

#### Teste manual da validação e do ponto de acesso

A seed cria os restaurantes, o operador e os estudantes, mas não as catracas nem o saldo.
Depois de `bin/rails db:seed`, complete pelo console:

```bash
bin/rails console
```

```ruby
darcy = Restaurant.find_by!(name: "RU Darcy Ribeiro")
Catraca.find_or_create_by!(restaurant: darcy, codigo: "CAT-01")
User.find_by!(matricula: "123456789").update!(saldo: 10)
exit
```

Em seguida, rode `bin/rails server` e:

1. Entre em `http://localhost:3000/operador/entrar` com a matrícula `1234567` e a senha
   `SenhaCorreta123`.
2. Abra `http://localhost:3000/ponto-de-acesso`, escolha `RU Darcy Ribeiro` e confirme.
3. Na tela de operação, clique em `CAT-01` e informe a matrícula `123456789`. A entrada é
   liberada e o saldo cai para R$ 5,50. Repita com `12345` (formato inválido) ou
   `999888777` (não cadastrada) para ver as recusas.
4. Confira os registros em `http://localhost:3000/admin/relatorio`.

#### Testes automatizados

```bash
bundle exec rspec spec/services/validacao_entrada_spec.rb spec/requests/catracas_spec.rb spec/requests/pontos_acesso_spec.rb spec/models/catraca_spec.rb
bundle exec cucumber features/validacao_entrada.feature features/configuracao_ponto_acesso.feature
```

### Histórico local da catraca

O funcionário acessa `GET /operador/historico` (login em `/operador/entrar`). A tela lista os
acessos, do mais recente para o mais antigo, só das catracas que o administrador vinculou a ele.
Mostra dois cartões (passagens liberadas e arrecadação do período) e uma tabela com horário,
matrícula, resultado (liberado, ou recusado com o motivo) e tarifa. Dá para filtrar por período
(dd/mm/aaaa) e por status. Com data inválida ou período invertido, a tela mostra o erro e não
calcula os cartões. Estudante e administrador recebem 403, e quem não está logado vai para a
autenticação.

### Gestão de restaurantes e catracas

O administrador acessa `GET /admin/restaurantes`. A tela tem cartões com o total de restaurantes,
de catracas e de catracas ativas, e um bloco por unidade com **Editar Unidade** e **Ver Catracas**.
Dá para cadastrar, editar, inativar, reativar e remover restaurantes, e cadastrar, editar e remover
catracas. Cada catraca tem responsável (funcionário ou administrador), status e uma janela de
funcionamento opcional, que precisa caber no horário do restaurante.

Regras principais: o nome do restaurante é único sem diferenciar maiúsculas; a capacidade vai de 1
a 5000; a abertura vem antes do fechamento; inativar o restaurante inativa as catracas ativas;
uma catraca com acessos registrados não muda de código nem de restaurante; a remoção é bloqueada
com a mensagem do motivo. O funcionário só consulta, e qualquer ação dele recebe 403.

### Extrato e histórico de refeições

O estudante acessa `GET /extrato` (login em `/login`). É uma tela só, com três cartões (total gasto
no mês, refeições realizadas e total recarregado), um filtro de período e duas listas: o extrato de
recargas, com todas as recargas e o status de cada uma, e o histórico de refeições, só com os
acessos liberados dele. A tela mostra apenas os dados do usuário logado. Filtro vazio não limita o
resultado, e data inválida mostra o erro. Funcionário e administrador recebem 403.

### Exportação em PDF do relatório de operação

No `GET /admin/relatorio`, com o período aplicado, o administrador clica em **Exportar PDF**
(`GET /admin/relatorio/exportar`). O PDF respeita o período e, se houver, os filtros de restaurante
e de catraca, e o nome do arquivo traz a catraca filtrada (`relatorio_operacao_<catraca>_<início>_a_<fim>.pdf`).
Sem registros no período, ou com filtro sem resultado, a tela mostra um aviso em vez de baixar o
arquivo. Datas inválidas, falha na geração e perfil sem permissão (403) têm página própria. O PDF é
gerado sem gem, por um gerador próprio em Ruby.

#### Testes dessas quatro funcionalidades

```bash
bundle exec rspec spec/requests/operador/historico_spec.rb spec/services/historico_local_spec.rb   spec/requests/extratos_spec.rb spec/services/extrato_historico_spec.rb spec/services/periodo_filtro_spec.rb   spec/requests/admin/gestao_spec.rb spec/models/catraca_spec.rb spec/models/restaurant_spec.rb   spec/services/inativacao_restaurante_spec.rb spec/requests/admin/exportacoes_spec.rb   spec/services/exportacao_relatorio_spec.rb spec/services/gerador_pdf_spec.rb

bundle exec cucumber features/historico_local_catraca.feature features/gestao_restaurantes.feature   features/gestao_catracas.feature features/extrato_historico.feature   features/exportacao_pdf_relatorio_operacao.feature
```

### Telas de entrada, menu e cardápio completo

A página inicial (`GET /`) é a porta de entrada: mostra o acesso de estudante, de operador e de administrador, o
login do estudante e os links de cadastro. Depois do login, o estudante vê a home com saldo, tarifa, turno atual e
cardápio, e o funcionário e o administrador vão direto para o Ponto de acesso e para a Gestão. Todas as telas do layout
básico têm um menu com os links de cada perfil.

O cardápio completo fica em `GET /cardapio/hoje` (café da manhã, almoço e jantar do dia, com a refeição em serviço
marcada) e `GET /cardapio/semana`. Ele usa uma API própria do cardápio (pasta `app/salvaguarda/cardapio_api`, veja o
`LEIA-ME.md` dela para configurar a URL e a chave) e cai nos dados importados do cardápio quando a API falha.

### Dados de exemplo

Na branch `sprint-2`, a seed popula usuários, restaurantes e acessos das duas
features. Ela é idempotente e pode ser executada novamente sem duplicar os dados:

```bash
git switch sprint-2
bin/rails db:seed
```

Após executar a seed, use `ana.silva@unb.br` ou a matrícula `123456789` como
referência do cadastro. Para testar o relatório, os dados incluem os restaurantes
`RU Darcy Ribeiro` e `RU Gama`, as catracas `CAT-01` e `CAT-02` e os resultados
`LIBERADO` e `NEGADO`.

### Testes

Na branch `sprint-2`, as duas issues e todas as migrations
estão disponíveis no mesmo checkout. Use um único banco de teste para executar a
suíte completa.

#### Preparação da branch e do banco

```bash
git switch sprint-2

TEST_DB_NAME=unb_ru_test \
RAILS_ENV=test \
bin/rails db:create db:migrate
```

O resultado esperado é:

```text
16 examples, 0 failures
```

#### RSpec completo

```bash
TEST_DB_NAME=unb_ru_test \
RAILS_ENV=test \
bundle exec rspec \
  spec/models/user_spec.rb \
  spec/requests/users_spec.rb \
  spec/models/access_spec.rb \
  spec/models/restaurant_spec.rb \
  spec/requests/admin/relatorios_spec.rb
```

Os specs verificam o cadastro de usuário, os models `Access` e `Restaurant`,
listagem de acessos, filtros, período, agrupamento, resultado vazio e bloqueio
de funcionário.

Para executar apenas uma feature:

```bash
TEST_DB_NAME=unb_ru_test RAILS_ENV=test \
bundle exec rspec spec/models/user_spec.rb spec/requests/users_spec.rb

TEST_DB_NAME=unb_ru_test RAILS_ENV=test \
bundle exec rspec spec/models/access_spec.rb spec/models/restaurant_spec.rb \
  spec/requests/admin/relatorios_spec.rb
```

Para testar a funcionalidade no navegador:

```bash
bin/rails server
```

Acesse <http://localhost:3000/cadastro/new> e teste:

- cadastro válido com nome, matrícula de nove dígitos e senha;
- envio sem preencher os campos;
- matrícula `123`;
- matrícula `999999999`;
- cadastro repetido com a mesma matrícula.

Para verificar o registro persistido:

```bash
bin/rails console
```

```ruby
user = User.find_by(matricula: "123456789")
user.name
user.matricula
user.password
```

#### Teste funcional no navegador

Inicie o servidor na branch `sprint-2`:

```bash
bin/rails server
```

Acesse <http://localhost:3000/cadastro/new> para testar o cadastro. Para testar o
relatório, acesse <http://localhost:3000/admin/relatorio>. Para inserir dados de teste,
abra o console Rails:

```bash
bin/rails console
```

```ruby
darcy = Restaurant.create!(name: "RU Darcy Ribeiro")
gama = Restaurant.create!(name: "RU Gama")

Access.create!(
  restaurant: darcy,
  catraca: "CAT-01",
  matricula: "241012345",
  resultado: "LIBERADO",
  occurred_at: Time.zone.parse("2026-10-20")
)

Access.create!(
  restaurant: darcy,
  catraca: "CAT-02",
  matricula: "241012346",
  resultado: "NEGADO",
  occurred_at: Time.zone.parse("2026-10-20")
)

Access.create!(
  restaurant: gama,
  catraca: "CAT-01",
  matricula: "241012347",
  resultado: "LIBERADO",
  occurred_at: Time.zone.parse("2026-10-21")
)
```

Teste a listagem sem filtros e depois:

```text
/admin/relatorio?catraca=CAT-01
/admin/relatorio?resultado=NEGADO
/admin/relatorio?date_from=2026-10-20&date_to=2026-10-21
/admin/relatorio?grouped=1
/admin/relatorio?catraca=CAT-99
```

O último endereço deve exibir `Nenhum acesso encontrado para os filtros
informados`.

#### Cucumber, RuboCop e CI

Os arquivos `.feature` são a especificação BDD das issues:

- `features/cadastro-usuario.feature`
- `features/relatorio_global_acessos.feature`

Os steps específicos dessas duas features ainda não estão implementados. O
RSpec é, portanto, a cobertura automatizada disponível para elas. O smoke test
do Cucumber pode ser executado com:

```bash
bundle exec cucumber features/saude.feature
bundle exec rubocop --fail-level E
```

O workflow de CI em `.github/workflows/ci.yml` executa os 16 exemplos RSpec,
o smoke test do Cucumber e o RuboCop em cada push e pull request.
