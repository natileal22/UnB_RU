# Salvaguarda de navegação

Esta pasta guarda arquivos de reserva para o grupo ter um menu em todas as páginas enquanto as telas
dos colegas não ficam prontas. Nada aqui mexe em rota, controller ou view de ninguém.

## Como funciona

- `config/initializers/salvaguarda.rb` coloca `app/salvaguarda/views` no **fim** da busca de views.
- As views reais ficam em `app/views`, que é procurada antes. Quando um colega criar o arquivo real,
  o dele vence sozinho e a reserva sai de graça.
- `shared/_navegacao.html.erb` é o menu, um só por perfil (visitante, estudante, funcionário e
  administrador), só com rotas que já existem.
- `operador/shared/_navbar.html.erb` é o partial que o `layouts/operador` já pedia e que não existia.
  Ele só chama o menu.
- A única mudança em arquivo compartilhado é uma linha no `layouts/application.html.erb`, que mostra
  o menu quando a reserva existe. Uma página que não quiser o menu usa `content_for :sem_menu`.

## O que está pendente com cada colega e como a reserva cobre

- **Natália:** tela Início & Carteira e o cabeçalho do portal. A reserva é só o menu, e a raiz
  continua sendo a página de saúde.
- **Pedro:** o login de `/operador/entrar` leva o funcionário para `/admin/restaurantes`. As rotas
  `/operador/ponto`, `/operador/terminal` e `/operador/validacoes` ainda não têm controller. O
  estudante não tem Sair próprio, e a reserva usa o Sair do operador para todos os perfis.
- **Adriano:** o Relatório Global ainda não tem layout próprio nem cartões. A reserva dá o menu no topo.
- **Isabela:** faltam links entre Ponto de acesso, Operação e Catraca. A reserva dá o menu com os dois
  primeiros.
- **Grupo:** funcionário e administrador só são criados por seed.

Quando o colega entregar o arquivo real, a reserva correspondente deixa de ser usada. Se todas as telas
estiverem prontas, a pasta `app/salvaguarda`, o initializer e a linha do layout podem ser apagados.
