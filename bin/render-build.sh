#!/usr/bin/env bash
# build do Render: instala as gems, compila os assets e aplica as migrations no banco de producao
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails db:migrate
# cardapio da semana no banco, a reserva da pagina de cardapio quando a API nao responde
bundle exec rails cardapio:importar

# dados de demonstracao so entram quando SEED_DEMO for true
if [ "$SEED_DEMO" = "true" ]; then
  bundle exec rails demo:popular
fi
