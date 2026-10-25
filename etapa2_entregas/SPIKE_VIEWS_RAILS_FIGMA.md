# Spike: views Rails das issues #3, #7 e #12 a partir do Figma

## Fonte

As telas vieram dos arquivos exportados do Figma, em PDF e SVG, que ficam na pasta `material das aulas`. Não acessei o Figma na web. Nos SVGs o texto está convertido em curvas, então li o texto dos PDFs (PyMuPDF) e conferi o layout renderizando os SVGs como imagem.

A numeração das telas no Figma (US) é diferente da numeração das issues:

| Issue | Tela no Figma | Arquivo | Perfil |
|---|---|---|---|
| #3 | Extrato e Histórico de Refeições (US04) | `Extrato de Refeições (US04)` | Estudante |
| #7 | Histórico Local da Catraca (US12) | `Histórico Local de Acessos (US12) - Simplificada` | Funcionário (fiscal da catraca) |
| #12 | Relatório Global de Operação (US16) | `Relatório Global de Operação (US16) - Simplificada` | Administrador (DAC/DUS) |

## Mapa completo das telas do Figma

O backup contém 12 telas, em PDF e SVG. Os números US do Figma não coincidem com os das issues do repositório da disciplina, e o quadro abaixo relaciona as duas numerações. As telas de FastPass correspondem ao épico bônus (issues #13 a #17).

| Tela no Figma | Issue | Perfil | Rota sugerida | Controller#action |
|---|---|---|---|---|
| Início & Carteira (US01, US02) | #10 (cardápio atual) | Estudante | `GET /` | `InicioController#show` |
| Recarga de Saldo (US03) | #2 | Estudante | `GET /recarga`, `POST /recarga` | `RecargasController#new`, `#create` |
| Extrato de Refeições (US04) | #3, #11 (botão Exportar PDF) | Estudante | `GET /extrato` | `ExtratosController#index` |
| Autenticação Operacional (US07) | #4 | Funcionário | `GET /operador/entrar`, `POST /operador/entrar` | `Operador::SessoesController#new`, `#create` |
| Configuração de Ponto (US08) | #5 | Funcionário e administrador | `GET /operador/ponto`, `PATCH /operador/ponto` | `Operador::PontosAcessoController#show`, `#update` |
| Terminal de Validação (US09, US10, US11) | #6 | Funcionário | `GET /operador/terminal`, `POST /operador/terminal/validacoes` | `Operador::TerminalController#show`, `Operador::ValidacoesController#create` |
| Histórico Local de Acessos (US12) | #7 | Funcionário | `GET /operador/historico` | `Operador::HistoricoController#index` |
| Gestão de Restaurantes e Catracas (US13) | #8 | Administrador | `/admin/restaurantes`, `/admin/catracas` | `Admin::RestaurantesController`, `Admin::CatracasController` |
| Relatório Global de Operação (US16) | #9, #12 (botão Exportar PDF) | Administrador | `GET /admin/relatorio` | `Admin::RelatoriosController#show` |
| Sorteio FastPass (US05, US06) | #14, #15 (bônus) | Estudante | `GET /fastpass`, `POST /fastpass/inscricoes` | `FastpassController#show`, `InscricoesFastpassController#create` |
| Turnos e Time-frames (US14) | #17 (bônus) | Administrador | `/admin/turnos` | `Admin::TurnosController` |
| Vagas e Cotas FastPass (US15) | #16 (bônus) | Administrador | `/admin/cotas` | `Admin::CotasFastpassController` |

O Cadastro de Usuário (#1) não tem tela no Figma. Os elementos de cada tela estão descritos abaixo.

| Tela | Elementos principais |
|---|---|
| Início & Carteira | Saldo em reais e em refeições, tarifa única de R$ 4,50, estado do turno atual, cardápio do almoço com três opções (padrão, ovolactovegetariana e vegetariana restrita), botão Recarregar Saldo e aviso do FastPass ativo. |
| Recarga de Saldo | Pacotes de refeições (2, 5, 10 e 20), campo de outra quantidade, escolha entre PIX e cartão de crédito, resumo com novo saldo, código PIX com botão Copiar Código e botão Confirmar. |
| Autenticação Operacional | Campo de matrícula SIAPE ou usuário, campo de senha (ambos obrigatórios) e botão Entrar no Sistema. |
| Configuração de Ponto | Seleção da unidade e da catraca física por piso, relógio do servidor (NTP), sessão de refeição, trava anti-reentrada, resumo da vinculação e botão Confirmar e Iniciar Operação. |
| Terminal de Validação | Modo Comum ou Exclusivo FastPass, leitura de QR Code, resultado (liberado ou bloqueado), identificação do estudante, débito e saldo restante, e tabela das últimas validações. |
| Gestão de Restaurantes e Catracas | Cartões de totais, botões Cadastrar Restaurante e Associar Nova Catraca, lista de unidades com Editar Unidade e Ver Catracas, e catracas agrupadas por piso com status. |
| Sorteio FastPass | Passe do próximo turno (contemplado), inscrição no sorteio com escolha de unidade e janela, ciclo diário de refeições e botão Liberar vaga. |
| Turnos e Time-frames | Três turnos com horários e modo FastPass, granularidade, tolerância e antecedência, grade de lotes de 15 minutos ativáveis, e botões Salvar e Restaurar Padrão. |
| Vagas e Cotas FastPass | Cota diária total, taxa de ocupação, capacidade por catraca, grade de janelas com cota e ajuste manual, e botão Aplicar Cotas ao Próximo Sorteio. |

## Arquitetura geral em Rails

**Três layouts.** As telas se dividem em três áreas visuais, cada uma com seu cabeçalho e navegação, e cada área vira um layout:
- `layouts/estudante.html.erb`: portal do estudante, com Início, Recarga, Extrato e FastPass, o saldo e o botão Sair.
- `layouts/operador.html.erb`: aplicação de controle, com Configuração de Ponto, Terminal de Validação e Histórico Local, o selo OPERACIONAL e a identificação do fiscal.
- `layouts/administracao.html.erb`: módulo de administração, com abas para Restaurantes e Catracas, Turnos, Vagas e Cotas e Relatório Global.

Cada controller declara o seu layout (`layout "estudante"`), e um `layouts/application.html.erb` mínimo concentra `<head>`, folhas de estilo e mensagens `flash`.

**Rotas.** O `config/routes.rb` agrupa as rotas por perfil:

```ruby
root "inicio#show"
resource :recarga, only: %i[new create]
get "extrato", to: "extratos#index"
namespace :operador do
  resource :sessao, only: %i[new create destroy]
  resource :ponto, only: %i[show update]
  resource :terminal, only: :show
  resources :validacoes, only: :create
  get "historico", to: "historico#index"
end
namespace :admin do
  resources :restaurantes
  resources :catracas, except: :destroy
  resource :relatorio, only: :show
  resources :turnos, :cotas_fastpass
end
```

As catracas não têm a rota `destroy`, em coerência com a regra de exclusão lógica: a inativação é uma ação `update` do status.

**Autorização.** Um `before_action :exigir_perfil` em cada controller base (`EstudanteController`, `Operador::BaseController`, `Admin::BaseController`) redireciona o visitante sem login para a autenticação e nega o acesso ao perfil incorreto, com mensagem, o que cobre os cenários de acesso negado das features.

**Componentes compartilhados** (`app/views/shared/`):
- `_cartao_resumo.html.erb`: título, valor em destaque e rodapé, usado nos cartões de Início, Extrato, Histórico e Relatório.
- `_filtros.html.erb`: formulário `GET` com selects e campos de data em dd/mm/aaaa.
- `_tabela.html.erb` e `_paginacao.html.erb`: tabela com cabeçalho fixo e paginação.
- `_selo_status.html.erb`: selo colorido para status (liberado, bloqueado, online, ativo).
- `_vazio.html.erb`: mensagem de lista vazia.
- `_botao_exportar.html.erb`: link com o mesmo caminho e a extensão `.pdf` ou `.csv`.

**Estilo.** O Figma usa a paleta azul do design system do governo (`#1351B4` nos botões e títulos) sobre fundo `#FCF9F8`, selos verdes e vermelhos para o status e cartões brancos com sombra leve. Essas cores entram como variáveis CSS em `app/assets/stylesheets/tokens.css`, compartilhadas pelos três layouts.

**Do SVG para a view.** Os SVGs exportados trazem o texto convertido em curvas e servem apenas como referência visual. A conversão para `.html.erb` segue a estrutura: cada faixa horizontal do desenho vira uma partial (cabeçalho, cartões, filtros, tabela), e os textos e valores fixos viram dados vindos dos models. Os valores de exemplo do Figma (R$ 72,00, 184 giros, 4.820 acessos) viram agregações (`sum`, `count`) sobre `Acesso` e `Recarga`.

**Testes.** Cada view entra no Cucumber com Capybara (`rack_test`), a partir dos cenários `.feature` do grupo.

## Tela da issue #3: Extrato e Histórico de Refeições (US04)

**Estrutura.** Cabeçalho do portal (Início, Recarga, Extrato, FastPass, nome, matrícula, saldo, Sair), título, botões **Exportar PDF** e **Imprimir**, três cartões de resumo, barra de filtros e a tabela de lançamentos com paginação.

**Cartões.** Total gasto no mês (R$ 72,00, 16 débitos de R$ 4,50), refeições realizadas (16, com divisão entre almoços, jantares e café) e total recarregado (R$ 90,00, com o saldo restante).

**Filtros.** Período de referência, tipo de refeição ou evento, restaurante, forma de acesso e o link **Limpar Filtros**.

**Tabela.** Colunas: data e hora, refeição ou evento, restaurante (com a catraca e o piso), método de acesso, valor e comprovante (**Ver Recibo**). Débitos aparecem em vermelho e recargas em verde (`+ R$ 45,00`). Rodapé com "Exibindo 1-5 de 24", itens por página e paginação.

**Rails.**
- `ExtratosController#index`, rota `GET /extrato`, com `before_action` para estudante autenticado.
- Os lançamentos juntam `current_user.recargas` e `current_user.acessos` numa lista ordenada por data decrescente. Um objeto de apresentação (`LancamentoExtrato`) converte os dois tipos para as mesmas colunas e define o sinal e a cor.
- Os cartões do topo são agregações (`sum`, `count`) sobre o mesmo recorte do filtro.
- Paginação com `pagy` ou `kaminari`, com o parâmetro de itens por página.
- Filtro por `GET`, com datas em dd/mm/aaaa lidas por `Date.strptime(valor, "%d/%m/%Y")`, que rejeita datas inexistentes. Data inicial posterior à final gera mensagem de erro. Sem resultados, a partial `_vazio` mostra a mensagem de lista vazia.
- **Exportar PDF** é um link para o mesmo caminho com `.pdf`. **Imprimir** é um botão com `window.print()` e CSS `@media print`.
- Em Rails, as views ficam em `app/views/extratos/` (`index.html.erb`, `_filtros`, `_resumo`, `_tabela`, `_vazio`).

**Diferenças em relação aos cenários.** O Figma traz filtros por tipo de refeição, restaurante e forma de acesso, e o cartão de resumo, que os cenários atuais não cobrem. O extrato de recargas (H3a) e o histórico de refeições (H3b) aparecem juntos na mesma tabela, enquanto a Wiki os trata como duas listas. Isso precisa ser alinhado com o grupo.

## Tela da issue #7: Histórico Local da Catraca (US12)

**Estrutura.** Cabeçalho operacional (Configuração de Ponto, Terminal de Validação, Histórico Local; usuário "Carlos M., Fiscal, Catraca 04"), título "Histórico Local da Catraca 04" com unidade, posto (catraca e piso) e turno, três cartões, barra de filtros e a tabela de acessos.

**Cartões.** Passagens no turno (184 giros confirmados), validações FastPass (142, 77,2% do total) e arrecadação local (R$ 828,00, 184 débitos de R$ 4,50).

**Filtros e ações.** Seletores **Status** (todos os registros) e **Modo** (todos os modos), botão **Atualizar Lista** e botão **Exportar Relatório (CSV/PDF)**.

**Tabela.** Colunas: horário, matrícula discente, modo de validação (Comum ou FastPass com janela), tarifa, status da catraca (liberado, ou bloqueado com o motivo, como saldo insuficiente ou janela expirada) e ação/auditoria. Linhas bloqueadas ficam destacadas em vermelho. Rodapé "Página 1 de 19".

**Rails.**
- `HistoricoCatracaController#index`, rota `GET /historico_catraca`, só para o funcionário. A consulta usa `Acesso.where(catraca: current_user.catracas)`.
- Os cartões são agregações do turno e da catraca sobre `Acesso` (`count`, `sum(:valor)`).
- Os filtros de status e modo viram `where` sobre `resultado` e sobre o modo de validação.
- A exportação reaproveita a ação com `respond_to` para `csv` e `pdf`.
- **Atualizar Lista** pode ser um link para a própria rota ou um `turbo_frame` com recarga da tabela.
- A cor da linha vem do `resultado` do acesso (`LIBERADO` ou `NEGADO`), e o motivo mostrado é o campo `motivo`, que a Validação de Entrada já grava.

**Diferenças em relação aos cenários.** O Figma mostra o filtro por status e modo, e os cenários pedem filtro por data (dd/mm/aaaa) e hora (HH:MM). A tela não tem campo de período. Também aparecem o modo FastPass e a janela de horário, que não existem nas features do repositório, e a tela inclui o botão de exportar CSV ou PDF.

## Tela da issue #12: Relatório Global de Operação (US16)

**Estrutura.** Cabeçalho de administração, abas (Restaurantes e Catracas, Turnos e Time-frames, Vagas e Cotas FastPass, Relatório Global de Operação), título, botões **Exportar CSV** e **Exportar PDF Oficial**, filtros, quatro cartões, tabela de consolidação, métodos de liquidação e distribuição por refeição.

**Filtros.** Data contábil, janela de serviço (turno) e unidade gestora. A tela mostra "Catracas Online: 6/6".

**Cartões.** Refeições servidas (4.820), arrecadação global (R$ 21.690,00), acessos via FastPass (1.150) e pontualidade FastPass (96,4%).

**Tabela.** Consolidação por restaurante: acessos, FastPass, pontualidade e arrecadação bruta, com linha de total. Ao lado, o percentual por método de liquidação (PIX e cartão) e a distribuição por refeição (café, almoço e jantar, com horários).

**Rails.**
- `RelatorioOperacaoController#show`, rota `GET /relatorio_operacao`, `before_action` exigindo administrador.
- Uma classe de consulta (`RelatorioOperacao`) recebe data, turno e unidade e devolve as agregações: `Acesso.liberados.group(:restaurante_id).count` e `sum(:valor)` por restaurante e por refeição, com `Recarga.group(:metodo)` para a liquidação. A mesma classe serve à tela e ao PDF.
- **Exportar PDF Oficial** é o mesmo caminho com `.pdf` (`respond_to`), gerado com `prawn` e `prawn-table`: período, data e hora de emissão, nome do administrador e a tabela de consolidação. Sem registros no período, a ação responde com aviso e não envia arquivo. Se a geração falhar, captura a exceção e mostra erro, e o `send_data` só roda depois de o PDF estar pronto.
- A tela deve usar a mesma consulta do Relatório Global de Acessos, de outro integrante, para os dois relatórios não divergirem.

**Diferenças em relação aos cenários.** O Figma exibe métricas de FastPass e turnos que não estão nas features do repositório. O PDF do cenário traz período, emissão e administrador, e o Figma não mostra essas informações na tela. As colunas do PDF continuam a definir com o grupo.

## Pontos em aberto

- A tela de Recarga do Figma vende pacotes de refeições (2, 5, 10 e 20), com o saldo mostrado também em refeições, enquanto os cenários tratam de valores em reais (R$ 30,00 por PIX e R$ 80,00 por cartão). O modelo adotado guarda o saldo em reais, e o pacote vira apenas um atalho de valor (quantidade × R$ 4,50).
- A tela de Autenticação do Figma aceita matrícula SIAPE ou usuário SIGAA/gov.br, e o cenário de autenticação exige matrícula de 7 dígitos.
- O Cadastro de Usuário (#1) não tem tela no Figma.
- A tela de Terminal de Validação mostra os modos Comum e Exclusivo FastPass, que não existem nos cenários de Validação de Entrada.

- O Figma inclui FastPass, turnos e vagas (US05, US06, US14, US15), funcionalidades que não estão nas features do repositório. O modelo ER entregue cobre só o que existe nas features.
- O Figma e as features divergem nos filtros do histórico local (status e modo contra período) e na separação entre extrato e histórico.
- A tela de Gestão de Restaurantes e Catracas (US13) mostra o piso da catraca, que entrou no modelo como `piso : Int`.
