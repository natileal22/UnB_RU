# language: pt

@issue-3
Funcionalidade: Extrato de recargas e histórico de refeições
  Como estudante
  Eu quero visualizar meu extrato de recargas e meu histórico de refeições
  Para ter controle sobre meus gastos e sobre minhas utilizações

  @feliz @extrato @hipotese
  Cenário: Filtrar o extrato por período incluindo os dias limites (Caminho Feliz)
    Dado que estou autenticado como o estudante "Ana Souza"
    E existem as recargas do estudante "Ana Souza":
      | data       | valor    |
      | 31/08/2026 | R$ 10,00 |
      | 01/09/2026 | R$ 20,00 |
      | 30/09/2026 | R$ 50,00 |
      | 01/10/2026 | R$ 15,00 |
    E estou na página "Extrato de Recargas"
    Quando dentro de "#filtro-periodo" preencho o campo "Data inicial" com "01/09/2026"
    E dentro de "#filtro-periodo" preencho o campo "Data final" com "30/09/2026"
    E dentro de "#filtro-periodo" clico no botão "Filtrar"
    Então a lista "#extrato-recargas" deve exibir "30/09/2026" antes de "01/09/2026"
    E o elemento "#extrato-recargas" não deve ter o texto "31/08/2026"
    E o elemento "#extrato-recargas" não deve ter o texto "01/10/2026"

  @feliz @historico @hipotese
  Cenário: Ver o histórico só com as refeições do próprio estudante (Caminho Feliz)
    Dado que estou autenticado como o estudante "Ana Souza"
    E existem os acessos do estudante "Ana Souza":
      | data       | hora  | catraca | restaurante      |
      | 10/09/2026 | 11:45 | CAT-01  | RU Darcy Ribeiro |
      | 11/09/2026 | 12:10 | CAT-02  | RU Darcy Ribeiro |
    E existem os acessos do estudante "Bruno Lima":
      | data       | hora  | catraca | restaurante      |
      | 12/09/2026 | 12:30 | CAT-01  | RU Darcy Ribeiro |
    Quando acesso a página "Histórico de Refeições"
    Então a lista "#historico-refeicoes" deve exibir "11/09/2026" antes de "10/09/2026"
    E o elemento "#historico-refeicoes" não deve ter o texto "12/09/2026"

  @triste @extrato @historico @hipotese
  Esquema do Cenário: Mostrar a lista vazia sem expor dados de outro estudante (Caminho Triste)
    Dado que estou autenticado como o estudante "Ana Souza"
    E só existem registros do estudante "Bruno Lima" na página "<pagina>"
    Quando acesso a página "<pagina>"
    Então o elemento "<vazio>" deve ter o texto "<mensagem>"
    E o elemento "<lista>" não deve existir na página

    Exemplos:
      | pagina                 | vazio            | mensagem                    | lista                |
      | Extrato de Recargas    | #extrato-vazio   | Nenhuma recarga encontrada  | #extrato-recargas    |
      | Histórico de Refeições | #historico-vazio | Nenhuma refeição encontrada | #historico-refeicoes |

  @triste @extrato @historico @rack_test @hipotese
  Esquema do Cenário: Redirecionar para a autenticação quando não há login (Caminho Triste)
    Dado que minha sessão expirou
    Quando acesso a página "<pagina>"
    Então devo ser redirecionado para a página "Autenticação"

    Exemplos:
      | pagina                 |
      | Extrato de Recargas    |
      | Histórico de Refeições |

  @triste @extrato @historico @hipotese
  Esquema do Cenário: Rejeitar período inválido no filtro (Caminho Triste)
    Dado que estou autenticado como o estudante "Ana Souza"
    E estou na página "<pagina>"
    Quando dentro de "#filtro-periodo" preencho o campo "Data inicial" com "<inicial>"
    E dentro de "#filtro-periodo" preencho o campo "Data final" com "<final>"
    E dentro de "#filtro-periodo" clico no botão "Filtrar"
    Então o elemento "#flash-alert" deve ter o texto "<mensagem>"

    Exemplos:
      | pagina                 | inicial    | final      | mensagem                                           |
      | Extrato de Recargas    | 30/09/2026 | 01/09/2026 | A data inicial não pode ser posterior à data final |
      | Extrato de Recargas    | 31/02/2026 | 28/02/2026 | Data inválida: use o formato dd/mm/aaaa            |
      | Histórico de Refeições | 01/09/2026 | abc        | Data inválida: use o formato dd/mm/aaaa            |
      | Histórico de Refeições | 20/09/2026 | 10/09/2026 | A data inicial não pode ser posterior à data final |

  @triste @extrato @historico @rack_test @hipotese
  Esquema do Cenário: Negar o extrato e o histórico a quem não é estudante (Caminho Triste)
    Dado que estou autenticado como "<perfil>"
    Quando acesso a página "<pagina>"
    Então a resposta deve ter status 403
    E o elemento "#flash-alert" deve ter o texto "Acesso negado: esta página é exclusiva do estudante"

    Exemplos:
      | pagina                 | perfil        |
      | Extrato de Recargas    | Funcionário   |
      | Extrato de Recargas    | Administrador |
      | Histórico de Refeições | Funcionário   |
      | Histórico de Refeições | Administrador |
