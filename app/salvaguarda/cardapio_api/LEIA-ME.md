# Cliente da API do cardápio (Vercel)

Esta pasta busca o cardápio semanal do RU Darcy Ribeiro na API publicada na Vercel
(`https://ru-unb-api.vercel.app`), sem alterar nenhum arquivo do restante do projeto Rails.

## Arquivos da pasta

- `cliente.rb`: define `CardapioApi::Cliente`, carregado automaticamente pelo Rails.
- `erro_api.rb`: define `CardapioApi::ErroApi`, o único erro que o cliente lança.
- `.env.example`: modelo sem a chave real para compartilhar com o grupo.
- `.env`: existe só na máquina de quem desenvolve e o `.gitignore` já o ignora, então a chave nunca vai
  para o Git.

## O que o cliente faz

- `CardapioApi::Cliente.semana_vigente`: chama `/cardapio/vigente` e devolve o hash da semana atual, com a lista
  `dias`.
- Qualquer falha vira `CardapioApi::ErroApi`: chave ausente, rede fora do ar, tempo esgotado, resposta com status
  de erro ou corpo que não é JSON. Quem chama só precisa tratar esse erro.
- A conexão é sempre HTTPS, com 10 segundos para conectar e 20 para ler.

## Configuração

O cliente lê as variáveis `RU_API_TOKEN` (obrigatória) e `RU_API_URL` (opcional, o padrão é o endereço acima):

- **Produção (Render):** cadastre as variáveis no painel de ambiente. O `.env` não existe lá.
- **Desenvolvimento e teste:** se a variável não estiver no ambiente, o cliente lê o `.env` desta pasta.

## Quem usa

O `CardapioDoDia` (`app/salvaguarda/cardapio_do_dia.rb`) chama `semana_vigente`, guarda o resultado no cache por
10 minutos e, se a API falhar, mostra o cardápio que está no banco (`Cardapio` e `ItemCardapio`).
