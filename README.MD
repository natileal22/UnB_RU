# UnB RU

Sistema de gerenciamento do Restaurante Universitário da Universidade de
Brasília, desenvolvido em Ruby on Rails.

## Sumário

- [Funcionalidades](#funcionalidades)
- [Requisitos](#requisitos)
- [Configuração](#configuração)
- [Banco de dados](#banco-de-dados)
- [Executando a aplicação](#executando-a-aplicação)
- [Testes](#testes)
- [Estrutura do projeto](#estrutura-do-projeto)
- [Contribuição](#contribuição)

## Funcionalidades

### Cadastro de usuário

Disponível em `/cadastro/new`. Permite que estudantes criem uma conta
informando:

- nome;
- matrícula de nove dígitos;
- senha.

O sistema valida campos obrigatórios, impede matrículas inválidas ou
duplicadas, persiste a conta e redireciona o estudante para a tela de login.

### Autenticação de funcionários

Funcionários e administradores podem acessar a autenticação do operador em
`/operador/entrar`. O acesso é validado por matrícula, senha e perfil.

### Configuração do ponto de acesso

Funcionários e administradores podem selecionar o restaurante em que irão
operar. Apenas restaurantes ativos ficam disponíveis para seleção.

### Validação de entrada

O sistema valida a matrícula apresentada na catraca, a disponibilidade da
catraca, o restaurante selecionado e o saldo do estudante. As tentativas,
liberadas ou negadas, são registradas para auditoria.

### Relatório global de acessos

Administradores acessam `/admin/relatorio` para consultar os registros de
acesso. O relatório permite:

- filtrar por restaurante;
- filtrar por catraca;
- filtrar por resultado;
- filtrar por período;
- agrupar por restaurante e catraca;
- consultar uma mensagem quando não há resultados.

## Requisitos

- Ruby 3.3 ou superior;
- Bundler;
- PostgreSQL 16 ou compatível;
- Node.js, quando necessário pelo ambiente Rails;
- Google Chrome/Chromium para cenários Capybara que utilizem JavaScript.

As versões das gems estão registradas em [Gemfile.lock](Gemfile.lock).

## Configuração

Instale as dependências:

```bash
bundle install
```

Se o projeto fornecer um arquivo `.env.example`, copie-o para `.env` e ajuste
as variáveis de ambiente:

```bash
cp .env.example .env
```

Sem uma conexão remota configurada, o projeto utiliza um PostgreSQL local com
as configurações definidas em `config/database.yml`.

Crie o banco e execute as migrações:

```bash
bin/rails db:create
bin/rails db:migrate
```

Para carregar os dados de exemplo:

```bash
bin/rails db:seed
```

A seed é idempotente e pode ser executada mais de uma vez sem duplicar os
registros previstos.

## Banco de dados

### Uso com Supabase

Para desenvolvimento compartilhado, configure `DATABASE_URL` com a conexão do
projeto Supabase. A porta `6543` (Supavisor, modo transação) é adequada para o
uso diário da aplicação.

### Migrações

Migrações devem usar uma conexão PostgreSQL na porta `5432` (pooler em modo
sessão ou conexão direta). Depois de executar as migrações, volte a usar a
conexão da porta `6543`, se aplicável.

### Proteção contra operações destrutivas

As tarefas de banco potencialmente destrutivas recusam conexões remotas por
padrão. Para executar conscientemente uma dessas operações, informe:

```bash
PERMITIR_BANCO_REMOTO=sim <comando>
```

### Credenciais Rails

O arquivo `config/credentials.yml.enc` está versionado, mas
`config/master.key` não deve ser versionado. Solicite a chave aos
responsáveis pelo projeto quando necessário.

## Executando a aplicação

Inicie o servidor:

```bash
bin/rails server
```

A aplicação estará disponível em <http://localhost:3000>.

Principais endereços:

| Recurso | Endereço |
| --- | --- |
| Página inicial | <http://localhost:3000/> |
| Cadastro | <http://localhost:3000/cadastro/new> |
| Login do estudante | <http://localhost:3000/login> |
| Login do operador | <http://localhost:3000/operador/entrar> |
| Relatório global | <http://localhost:3000/admin/relatorio> |

## Testes

Antes de executar os testes, prepare o banco de teste:

```bash
RAILS_ENV=test bin/rails db:test:prepare
```

### RSpec

Execute toda a suíte:

```bash
bundle exec rspec
```

Execute apenas os testes das issues #1 e #9:

```bash
bundle exec rspec \
  spec/requests/users_spec.rb \
  spec/requests/admin/relatorios_spec.rb
```

### Cucumber e Capybara

Execute todas as features implementadas:

```bash
bundle exec cucumber --strict --publish-quiet \
  features/saude.feature \
  features/autenticacao_funcionario.feature \
  features/validacao_entrada.feature \
  features/configuracao_ponto_acesso.feature \
  features/cadastro-usuario.feature \
  features/relatorio_global_acessos.feature
```

Execute somente as features das issues #1 e #9:

```bash
bundle exec cucumber --strict --publish-quiet \
  features/cadastro-usuario.feature \
  features/relatorio_global_acessos.feature
```

Os arquivos `.feature` contêm as especificações BDD, enquanto os steps ficam
em [features/step_definitions](features/step_definitions).

### RuboCop

Analise o código com:

```bash
bundle exec rubocop --fail-level E
```

### Integração contínua

O workflow em [.github/workflows/ci.yml](.github/workflows/ci.yml) é executado
em pushes e pull requests. Ele prepara o banco de teste, executa o RSpec, as
features implementadas do Cucumber/Capybara e o RuboCop.

## Estrutura do projeto

```text
app/
  controllers/     Controllers HTTP
  models/          Models Active Record
  services/        Regras de negócio reutilizáveis
  views/           Templates das páginas
config/             Rotas e configurações Rails
db/                 Migrações, schema e seeds
features/           Especificações Cucumber/Capybara
spec/               Testes RSpec
docs/               Documentação e artefatos do projeto
```

## Contribuição

1. Crie uma branch a partir da branch de trabalho atual.
2. Implemente a alteração acompanhada de testes.
3. Execute RSpec, Cucumber/Capybara e RuboCop.
4. Atualize a documentação relacionada.
5. Abra um pull request descrevendo a alteração e os testes executados.

Consulte [Wiki.md](Wiki.md) para as regras de negócio, responsáveis e
documentação das funcionalidades da sprint.
