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

