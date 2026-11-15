# Salvaguarda de navegação

Esta pasta guarda arquivos de reserva para o grupo ter porta de entrada, home do estudante e menu em
todas as páginas enquanto as telas dos colegas não ficam prontas. Nada aqui altera view ou controller
de colega.

## Como funciona

- `config/initializers/salvaguarda.rb` coloca `app/salvaguarda/views` no **fim** da busca de views e
  libera o css de `app/salvaguarda/assets/stylesheets`.
- As views reais ficam em `app/views`, que é procurada antes. Quando um colega criar o arquivo real,
  o dele vence sozinho e a reserva sai de graça.
- `inicio_controller.rb` e as views de `inicio/` são a página inicial: o visitante vê a porta de
  entrada (estilo SIGAA, com o login do estudante e os acessos do operador e do administrador), o
  estudante vê a home do Figma (saldo, tarifa, turno e cardápio), o funcionário vai para o Ponto de
  acesso e o administrador para a Gestão. O `sair` serve ao estudante.
- `shared/_navegacao.html.erb` é o menu, um só por perfil, só com rotas que já existem.
- `operador/shared/_navbar.html.erb` é o partial que o `layouts/operador` já pedia. Ele só chama o menu.
- `cardapio_do_dia.rb` e `cardapio_completo_controller.rb` são o cardápio completo: `/cardapio/hoje` mostra café,
  almoço e jantar do dia com a refeição em serviço marcada, e `/cardapio/semana` mostra os 7 dias. Os dados vêm
  da API do cardápio (`cardapio_api/cliente.rb`) e, se ela falhar, do banco (`Cardapio` e `ItemCardapio`). Os
  horários vêm do `HorarioRefeicao`. A página da Natália em `/cardapio` segue como está.
- `assets/stylesheets/salvaguarda.css` tem a paleta do Figma e uma harmonização mínima de `auth-card`,
  `field` e `primary-button`.

## Mudanças em arquivo compartilhado

- `config/routes.rb`: `root "inicio#show"` no lugar de `saude#index`, a rota `delete "sair"` e as rotas
  `cardapio/hoje` e `cardapio/semana`.
- `layouts/application.html.erb`: uma linha que mostra o menu quando a reserva existe.

## O que está pendente com cada colega e como a reserva cobre

- **Natália (cardápio):** a página `/cardapio` mostra só a refeição do momento. A reserva mostra o dia completo e
  a semana. O token da API fica no `.env` local (ignorado pelo git), e o `.env.example` mostra o formato.
- **Natália:** tela Início & Carteira real. A reserva monta a home com os dados dela (`HorarioRefeicao`,
  `Cardapio`). Quando ela entregar um `InicioController`, apague esta pasta e a linha do `root`.
- **Pedro:** login e logout do estudante, e o login do `/operador/entrar` leva o funcionário para
  `/admin/restaurantes`. As rotas `/operador/ponto`, `/operador/terminal` e `/operador/validacoes`
  ainda não têm controller. A reserva dá o `sair` do estudante e a porta de entrada.
- **Adriano:** o Relatório Global ainda não tem layout próprio nem cartões. A reserva dá o menu no topo.
- **Isabela:** faltam links entre Ponto de acesso, Operação e Catraca. A reserva dá o menu com os dois
  primeiros.
- **Grupo:** funcionário e administrador só são criados por seed.

A tela de login do operador (`/operador/entrar`) usa o layout dele, que não carrega o css da reserva,
então ela segue com o visual atual até o Pedro entregar a versão do Figma.

Quando o colega entregar o arquivo real, a reserva correspondente deixa de ser usada. Se todas as telas
estiverem prontas, a pasta `app/salvaguarda`, o initializer e a linha do layout podem ser apagados.
