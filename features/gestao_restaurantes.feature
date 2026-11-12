# language: pt
@mvp @issue-8 @restaurantes
Funcionalidade: Gestão de Restaurantes
  Como administrador
  Eu quero cadastrar, listar, editar, ativar/inativar e remover restaurantes universitários
  Para que as catracas e os funcionários da Aplicação de Controle saibam quais unidades existem e em que estado estão

  @feliz @cadastro
  Esquema do Cenário: Cadastrar restaurante com dados válidos
    Dado que estou autenticado como "Administrador"
    E estou na página "Gestão de Restaurantes e Catracas"
    E a validação nativa do navegador está desativada no formulário "#new_restaurant"
    Quando clico no botão "+ Cadastrar Restaurante"
    E dentro de "#new_restaurant" preencho o campo "Nome" com "RU Darcy Ribeiro"
    E dentro de "#new_restaurant" preencho o campo "Localização" com "Campus Darcy Ribeiro"
    E dentro de "#new_restaurant" preencho o campo "Capacidade" com "<capacidade>"
    E dentro de "#new_restaurant" preencho o campo "Abertura" com "11:00"
    E dentro de "#new_restaurant" preencho o campo "Fechamento" com "14:00"
    E dentro de "#new_restaurant" clico no botão "Salvar"
    Então o elemento "#flash-notice" deve ter o texto "Restaurante cadastrado com sucesso"
    E o elemento "#status-restaurante-ru-darcy-ribeiro" deve ter o texto exato "Ativo"

    Exemplos:
      | capacidade |
      | 1          |
      | 500        |
      | 5000       |

  @triste @cadastro @validacao
  Esquema do Cenário: Rejeitar cadastro com dados inválidos
    Dado que estou autenticado como "Administrador"
    E estou na página "Gestão de Restaurantes e Catracas"
    E a validação nativa do navegador está desativada no formulário "#new_restaurant"
    Quando clico no botão "+ Cadastrar Restaurante"
    E dentro de "#new_restaurant" preencho o campo "Nome" com "<nome>"
    E dentro de "#new_restaurant" preencho o campo "Localização" com "<localizacao>"
    E dentro de "#new_restaurant" preencho o campo "Capacidade" com "<capacidade>"
    E dentro de "#new_restaurant" preencho o campo "Abertura" com "<abertura>"
    E dentro de "#new_restaurant" preencho o campo "Fechamento" com "<fechamento>"
    E dentro de "#new_restaurant" clico no botão "Salvar"
    Então o elemento "#flash-alert" deve ter o texto "<mensagem>"
    E nenhum restaurante deve estar cadastrado
    E dentro de "#new_restaurant" o campo "Nome" deve continuar preenchido com "<nome>"

    Exemplos:
      | nome             | localizacao          | capacidade | abertura | fechamento | mensagem                                                         |
      | RU Darcy Ribeiro | Campus Darcy Ribeiro | 0          | 11:00    | 14:00      | Capacidade inválida: informe um número inteiro entre 1 e 5000    |
      | RU Darcy Ribeiro | Campus Darcy Ribeiro | 5001       | 11:00    | 14:00      | Capacidade inválida: informe um número inteiro entre 1 e 5000    |
      | RU Darcy Ribeiro | Campus Darcy Ribeiro | -1         | 11:00    | 14:00      | Capacidade inválida: informe um número inteiro entre 1 e 5000    |
      | RU Darcy Ribeiro | Campus Darcy Ribeiro | 10,5       | 11:00    | 14:00      | Capacidade inválida: informe um número inteiro entre 1 e 5000    |
      | RU Darcy Ribeiro | Campus Darcy Ribeiro | abc        | 11:00    | 14:00      | Capacidade inválida: informe um número inteiro entre 1 e 5000    |
      | RU Darcy Ribeiro | Campus Darcy Ribeiro |            | 11:00    | 14:00      | Capacidade inválida: informe um número inteiro entre 1 e 5000    |
      |                  | Campus Darcy Ribeiro | 500        | 11:00    | 14:00      | Nome do restaurante é obrigatório                                |
      | RU Darcy Ribeiro |                      | 500        | 11:00    | 14:00      | Localização do restaurante é obrigatória                         |
      | RU Darcy Ribeiro | Campus Darcy Ribeiro | 500        | 14:00    | 11:00      | O horário de abertura deve ser anterior ao horário de fechamento |
      | RU Darcy Ribeiro | Campus Darcy Ribeiro | 500        | 11:00    | 11:00      | O horário de abertura deve ser anterior ao horário de fechamento |
      | RU Darcy Ribeiro | Campus Darcy Ribeiro | 500        |          | 14:00      | Horário de abertura é obrigatório                                |
      | RU Darcy Ribeiro | Campus Darcy Ribeiro | 500        | 11:00    |            | Horário de fechamento é obrigatório                              |
      | RU Darcy Ribeiro | Campus Darcy Ribeiro | 500        | 25:99    | 14:00      | Horário de abertura é inválido                                   |

  @triste @cadastro @unicidade
  Esquema do Cenário: Rejeitar nome de restaurante já existente variando a caixa
    Dado que estou autenticado como "Administrador"
    E existe o restaurante "RU Darcy Ribeiro"
    E estou na página "Gestão de Restaurantes e Catracas"
    E a validação nativa do navegador está desativada no formulário "#new_restaurant"
    Quando clico no botão "+ Cadastrar Restaurante"
    E dentro de "#new_restaurant" preencho o campo "Nome" com "<nome>"
    E dentro de "#new_restaurant" preencho o campo "Localização" com "Campus Gama"
    E dentro de "#new_restaurant" preencho o campo "Capacidade" com "300"
    E dentro de "#new_restaurant" preencho o campo "Abertura" com "11:00"
    E dentro de "#new_restaurant" preencho o campo "Fechamento" com "14:00"
    E dentro de "#new_restaurant" clico no botão "Salvar"
    Então o elemento "#flash-alert" deve ter o texto "Já existe um restaurante com este nome"
    E deve existir exatamente 1 restaurante no banco

    Exemplos:
      | nome             |
      | RU Darcy Ribeiro |
      | ru darcy ribeiro |
      | RU DARCY RIBEIRO |

  @feliz @listagem
  Cenário: Listar restaurantes em ordem alfabética
    Dado que estou autenticado como "Administrador"
    E existem os restaurantes:
      | nome             |
      | RU Gama          |
      | RU Darcy Ribeiro |
    Quando acesso a página "Gestão de Restaurantes e Catracas"
    Então a lista "#restaurantes" deve exibir "RU Darcy Ribeiro" antes de "RU Gama"

  @feliz @edicao
  Esquema do Cenário: Editar cada campo de um restaurante
    Dado que estou autenticado como "Administrador"
    E existe o restaurante "RU Darcy Ribeiro" com:
      | localizacao | Campus Darcy Ribeiro |
      | capacidade  | 500                  |
      | abertura    | 11:00                |
      | fechamento  | 14:00                |
    E estou na página "Gestão de Restaurantes e Catracas"
    E a validação nativa do navegador está desativada no formulário de edição do restaurante "RU Darcy Ribeiro"
    Quando clico em "#editar-restaurante-ru-darcy-ribeiro"
    E dentro do formulário de edição do restaurante "RU Darcy Ribeiro" preencho o campo "<campo>" com "<valor>"
    E dentro do formulário de edição do restaurante "RU Darcy Ribeiro" clico no botão "Salvar"
    Então o elemento "#flash-notice" deve ter o texto "Restaurante atualizado com sucesso"
    E o elemento "<linha>" deve ter o texto "<valor>"

    Exemplos:
      | campo       | valor        | linha                         |
      | Nome        | RU Asa Norte | #restaurante-ru-asa-norte     |
      | Localização | Campus Gama  | #restaurante-ru-darcy-ribeiro |
      | Capacidade  | 800          | #restaurante-ru-darcy-ribeiro |
      | Abertura    | 10:30        | #restaurante-ru-darcy-ribeiro |
      | Fechamento  | 15:00        | #restaurante-ru-darcy-ribeiro |

  @feliz @status @cascata
  Cenário: Inativar restaurante inativa as catracas Ativas e mantém as Em Manutenção
    Dado que estou autenticado como "Administrador"
    E existe o restaurante "RU Darcy Ribeiro"
    E existem as catracas no restaurante "RU Darcy Ribeiro":
      | codigo | status        |
      | CAT-01 | Ativa         |
      | CAT-02 | Em Manutenção |
    E estou na página "Gestão de Restaurantes e Catracas"
    Quando clico em "#inativar-restaurante-ru-darcy-ribeiro"
    Então o elemento "#flash-notice" deve ter o texto "Restaurante e suas catracas ativas foram inativados"
    E o elemento "#status-restaurante-ru-darcy-ribeiro" deve ter o texto exato "Inativo"
    E o elemento "#status-catraca-ru-darcy-ribeiro--cat-01" deve ter o texto exato "Inativa"
    E o elemento "#status-catraca-ru-darcy-ribeiro--cat-02" deve ter o texto exato "Em Manutenção"

  @feliz @remocao
  Cenário: Remover restaurante sem catracas após aceitar a confirmação
    Dado que estou autenticado como "Administrador"
    E existe o restaurante "RU Darcy Ribeiro"
    E estou na página "Gestão de Restaurantes e Catracas"
    Quando clico em "#remover-restaurante-ru-darcy-ribeiro" e aceito a confirmação "Deseja realmente remover o restaurante?"
    Então o elemento "#flash-notice" deve ter o texto "Restaurante removido com sucesso"
    E o restaurante "RU Darcy Ribeiro" não deve existir

  @triste @remocao
  Cenário: Não remover restaurante que possui catracas vinculadas
    Dado que estou autenticado como "Administrador"
    E existe o restaurante "RU Darcy Ribeiro"
    E existe a catraca "CAT-01" no restaurante "RU Darcy Ribeiro" com:
      | status | Inativa |
    E estou na página "Gestão de Restaurantes e Catracas"
    Quando clico em "#remover-restaurante-ru-darcy-ribeiro"
    Então o elemento "#flash-alert" deve ter o texto "Não é possível remover um restaurante com catracas vinculadas. Remova as catracas antes ou apenas inative o restaurante"
    E o restaurante "RU Darcy Ribeiro" deve continuar existindo

  @triste @autorizacao @rack_test
  Esquema do Cenário: Funcionário não pode executar ações administrativas
    Dado que existe o restaurante "RU Darcy Ribeiro"
    E estou autenticado como "Funcionário"
    Quando envio uma requisição "<metodo>" para a rota "<rota>" do restaurante "RU Darcy Ribeiro"
    Então a resposta deve ter status 403
    E o elemento "#flash-alert" deve ter o texto "Acesso negado: apenas o Administrador pode realizar esta ação"
    E o restaurante "RU Darcy Ribeiro" deve permanecer inalterado

    Exemplos:
      | metodo | rota     |
      | GET    | novo     |
      | POST   | criar    |
      | GET    | editar   |
      | PATCH  | editar   |
      | DELETE | remover  |
      | PATCH  | inativar |
      | PATCH  | ativar   |

  @triste @autorizacao @sessao
  Cenário: Sessão expirada redireciona para a autenticação
    Dado que minha sessão expirou
    Quando acesso a página "Gestão de Restaurantes e Catracas"
    Então devo ser redirecionado para a página "Autenticação"
