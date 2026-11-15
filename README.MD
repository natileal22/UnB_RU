# UnB RU

---

Sistema de gerenciamento para o Restaurante Universitário da UnB.

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

### Dados de exemplo

Na branch consolidada, a seed popula usuários, restaurantes e acessos das duas
features. Ela é idempotente e pode ser executada novamente sem duplicar os dados:

```bash
git switch feat/adriano-issue_1_9
bin/rails db:seed
```

Após executar a seed, use `ana.silva@unb.br` ou a matrícula `123456789` como
referência do cadastro. Para testar o relatório, os dados incluem os restaurantes
`RU Darcy Ribeiro` e `RU Gama`, as catracas `CAT-01` e `CAT-02` e os resultados
`LIBERADO` e `NEGADO`.

### Testes

Na branch consolidada `feat/adriano-issue_1_9`, as duas issues e todas as migrations
estão disponíveis no mesmo checkout. Use um único banco de teste para executar a
suíte completa.

#### Preparação da branch e do banco

```bash
git switch feat/adriano-issue_1_9

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

Inicie o servidor na branch consolidada:

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
