# language: pt

@issue-7
Funcionalidade: Histórico local da catraca
  Como funcionário
  Eu quero visualizar na aplicação de controle o histórico de todos os acessos registrados apenas na catraca que estou gerenciando no momento
  Para realizar auditorias ou conferências locais de fluxo

  Contexto:
    Dado que existe o restaurante "RU Darcy Ribeiro"

  @feliz @historico @hipotese
  Cenário: Listar os acessos liberados e recusados das catracas vinculadas ao funcionário (Caminho Feliz)
    Dado que estou autenticado como "Funcionário"
    E existem os acessos na catraca "CAT-01" do restaurante "RU Darcy Ribeiro":
      | data       | hora  | matricula | resultado                                    |
      | 10/09/2026 | 11:45 | 241012345 | Liberado                                     |
      | 10/09/2026 | 11:50 | 241067890 | Recusado: Saldo insuficiente para a refeição |
    E existem os acessos na catraca "CAT-03" do restaurante "RU Darcy Ribeiro":
      | data       | hora  | matricula | resultado |
      | 10/09/2026 | 12:20 | 241055555 | Liberado  |
    E existem os acessos na catraca "CAT-02" do restaurante "RU Darcy Ribeiro":
      | data       | hora  | matricula | resultado |
      | 10/09/2026 | 12:05 | 241099999 | Liberado  |
    E a catraca "CAT-01" do restaurante "RU Darcy Ribeiro" está vinculada ao funcionário
    E a catraca "CAT-03" do restaurante "RU Darcy Ribeiro" está vinculada ao funcionário
    Quando acesso a página "Histórico Local"
    Então a lista "#acessos" deve exibir "Liberado"
    E a lista "#acessos" deve exibir "Recusado: Saldo insuficiente para a refeição"
    E a lista "#acessos" deve exibir "241055555"
    E o elemento "#acessos" não deve ter o texto "241099999"

  @triste @historico @rack_test @hipotese
  Cenário: Redirecionar para a autenticação quando não há login (Caminho Triste)
    Dado que minha sessão expirou
    Quando acesso a página "Histórico Local"
    Então devo ser redirecionado para a página "Autenticação"

  @triste @historico @hipotese
  Cenário: Orientar a procurar o administrador quando não há catraca vinculada (Caminho Triste)
    Dado que estou autenticado como "Funcionário"
    E nenhuma catraca está vinculada ao funcionário
    Quando acesso a página "Histórico Local"
    Então o elemento "#aviso-sem-catraca" deve ter o texto "Nenhuma catraca vinculada a você. Procure o administrador"
    E o elemento "#acessos" não deve existir na página

  @triste @historico @hipotese
  Cenário: Mostrar mensagem quando a catraca não tem acessos (Caminho Triste)
    Dado que estou autenticado como "Funcionário"
    E existe a catraca "CAT-01" no restaurante "RU Darcy Ribeiro" com:
      | status | Ativa |
    E a catraca "CAT-01" do restaurante "RU Darcy Ribeiro" está vinculada ao funcionário
    Quando acesso a página "Histórico Local"
    Então o elemento "#acessos-vazio" deve ter o texto "Nenhum acesso registrado nesta catraca"

  @triste @historico @hipotese
  Esquema do Cenário: Rejeitar período inválido no filtro (Caminho Triste)
    Dado que estou autenticado como "Funcionário"
    E a catraca "CAT-01" do restaurante "RU Darcy Ribeiro" está vinculada ao funcionário
    E estou na página "Histórico Local"
    Quando dentro de "#filtro-periodo" preencho o campo "Data inicial" com "<inicial>"
    E dentro de "#filtro-periodo" preencho o campo "Data final" com "<final>"
    E dentro de "#filtro-periodo" clico no botão "Filtrar"
    Então o elemento "#flash-alert" deve ter o texto "<mensagem>"

    Exemplos:
      | inicial    | final      | mensagem                                           |
      | 30/09/2026 | 01/09/2026 | A data inicial não pode ser posterior à data final |
      | 31/02/2026 | 28/02/2026 | Data inválida: use o formato dd/mm/aaaa            |
      | 01/09/2026 | abc        | Data inválida: use o formato dd/mm/aaaa            |

  @triste @historico @rack_test @hipotese
  Esquema do Cenário: Negar o histórico local a quem não é funcionário (Caminho Triste)
    Dado que estou autenticado como "<perfil>"
    Quando acesso a página "Histórico Local"
    Então a resposta deve ter status 403
    E o elemento "#flash-alert" deve ter o texto "Acesso negado: esta página é exclusiva do funcionário"

    Exemplos:
      | perfil        |
      | Estudante     |
      | Administrador |
