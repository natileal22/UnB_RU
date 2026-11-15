# Cliente isolado da API do cardapio (Vercel)

Esta pasta fica dentro de `app/salvaguarda/cardapio_api` para buscar o cardapio semanal do RU
Darcy Ribeiro pela API publicada na Vercel (`https://ru-unb-api.vercel.app`), sem alterar nenhum
arquivo do restante do projeto Rails.

## Arquivos da pasta

- `.env`: guarda a URL (`RU_API_URL`) e a chave de acesso (`RU_API_TOKEN`) da API na Vercel.
  O `.gitignore` da raiz já ignora arquivos `.env`, evitando vazamento da chave no Git.
- `.env.example`: modelo sem a senha real para compartilhar com o grupo.
- `cliente.rb`: define `CardapioApi::Cliente` (carregado automaticamente pelo Rails).

## Métodos disponíveis em `CardapioApi::Cliente`

- `CardapioApi::Cliente.semana_vigente`: chama `/cardapio/vigente` e retorna os 7 dias da semana atual.
- `CardapioApi::Cliente.proxima_semana`: chama `/cardapio/proxima-semana` quando já publicada.
- `CardapioApi::Cliente.completo`: chama `/cardapio` com semana vigente + próxima semana + validação.
- `CardapioApi::Cliente.para_cardapio_json`: converte os dados da API para o mesmo formato do `cardapio.json`.
- `CardapioApi::Cliente.importar_semana_vigente!`: grava direto em `Cardapio` e `ItemCardapio` no banco.

## Onde e como conectar depois (quando você decidir integrar)

### Opção 1 — Pela rake task `lib/tasks/cardapio.rake` (recomendada)

Em vez de ler `Rails.root.join('cardapio.json')`, basta trocar uma linha para:

```ruby
semana = CardapioApi::Cliente.para_cardapio_json
```

Ou chamar direto no console/task/agendamento:

```ruby
CardapioApi::Cliente.importar_semana_vigente!
```

### Opção 2 — Sob demanda no `CardapiosController#show`

```ruby
if @refeicao && @cardapio.nil?
  CardapioApi::Cliente.importar_semana_vigente!
  @cardapio = Cardapio.includes(:itens).find_by(data: Time.zone.today, refeicao: @refeicao.chave)
end
```

### Em produção (Vercel / servidor do Rails)

O `CardapioApi::Cliente` lê primeiro `ENV['RU_API_URL']` e `ENV['RU_API_TOKEN']`. Assim, basta
cadastrar essas duas variáveis no painel de ambiente (ou usar este `.env` localmente).
