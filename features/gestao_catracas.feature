# language: pt
@mvp @issue-8 @catracas
Funcionalidade: Gestão de Catracas
  Como administrador
  Eu quero cadastrar, editar, alterar o status e remover catracas vinculadas a um restaurante
  Para que cada unidade tenha as catracas físicas que os funcionários poderão selecionar

  Contexto:
    Dado que existe o restaurante "RU Darcy Ribeiro"
    E existe o funcionário "Carlos Mendes"
    E existe o estudante "Ana Souza"

  @feliz @cadastro
  Esquema do Cenário: Cadastrar catraca vinculada a um restaurante Ativo
    Dado que estou autenticado como "Administrador"
    E estou na página "Gestão de Restaurantes e Catracas"
    E a validação nativa do navegador está desativada no formulário "#new_turnstile"
    Quando clico no botão "+ Associar Nova Catraca"
    E dentro de "#new_turnstile" preencho o campo "Código" com "CAT-01"
    E dentro de "#new_turnstile" seleciono "RU Darcy Ribeiro" no campo "Restaurante"
    E dentro de "#new_turnstile" seleciono "<status>" no campo "Status"
    E dentro de "#new_turnstile" seleciono "Carlos Mendes" no campo "Responsável"
    E dentro de "#new_turnstile" clico no botão "Salvar"
    Então o elemento "#flash-notice" deve ter o texto "Catraca cadastrada com sucesso"
    E o elemento "#status-catraca-ru-darcy-ribeiro--cat-01" deve ter o texto exato "<status>"
    E o responsável pela catraca "CAT-01" do restaurante "RU Darcy Ribeiro" deve ser "Carlos Mendes"

    Exemplos:
      | status        |
      | Ativa         |
      | Inativa       |
      | Em Manutenção |

  @triste @cadastro @validacao
  Cenário: Não oferecer estudante como responsável pela catraca
    Dado que estou autenticado como "Administrador"
    E estou na página "Gestão de Restaurantes e Catracas"
    Quando clico no botão "+ Associar Nova Catraca"
    Então o campo "Responsável" deve oferecer "Carlos Mendes"
    E o campo "Responsável" não deve oferecer "Ana Souza"

  @triste @cadastro @validacao
  Esquema do Cenário: Rejeitar código de catraca com formato inválido
    Dado que estou autenticado como "Administrador"
    E estou na página "Gestão de Restaurantes e Catracas"
    E a validação nativa do navegador está desativada no formulário "#new_turnstile"
    Quando clico no botão "+ Associar Nova Catraca"
    E dentro de "#new_turnstile" preencho o campo "Código" com "<codigo>"
    E dentro de "#new_turnstile" seleciono "RU Darcy Ribeiro" no campo "Restaurante"
    E dentro de "#new_turnstile" seleciono "Inativa" no campo "Status"
    E dentro de "#new_turnstile" clico no botão "Salvar"
    Então o elemento "#flash-alert" deve ter o texto "Código da catraca contém caracteres inválidos"
    E não deve existir nenhuma catraca no restaurante "RU Darcy Ribeiro"

    Exemplos:
      | codigo |
      | CAT 01 |
      | CAT#01 |
      | CAT/01 |

  @triste @cadastro @validacao
  Esquema do Cenário: Rejeitar código de catraca vazio ou acima do tamanho máximo
    Dado que estou autenticado como "Administrador"
    E estou na página "Gestão de Restaurantes e Catracas"
    Quando clico no botão "+ Associar Nova Catraca"
    E dentro de "#new_turnstile" preencho o campo "Código" com "<codigo>"
    E dentro de "#new_turnstile" seleciono "RU Darcy Ribeiro" no campo "Restaurante"
    E dentro de "#new_turnstile" seleciono "Inativa" no campo "Status"
    E dentro de "#new_turnstile" clico no botão "Salvar"
    Então o elemento "#flash-alert" deve ter o texto "<mensagem>"
    E não deve existir nenhuma catraca no restaurante "RU Darcy Ribeiro"

    Exemplos:
      | codigo                | mensagem                                           |
      |                       | Código da catraca é obrigatório                    |
      | ABCDEFGHIJKLMNOPQRSTU | Código da catraca deve ter no máximo 20 caracteres |

  @feliz @cadastro @horario
  Cenário: Cadastrar catraca com horário de funcionamento
    Dado que estou autenticado como "Administrador"
    E estou na página "Gestão de Restaurantes e Catracas"
    Quando clico no botão "+ Associar Nova Catraca"
    E dentro de "#new_turnstile" preencho o campo "Código" com "CAT-01"
    E dentro de "#new_turnstile" seleciono "RU Darcy Ribeiro" no campo "Restaurante"
    E dentro de "#new_turnstile" seleciono "Ativa" no campo "Status"
    E dentro de "#new_turnstile" preencho o campo "Abertura" com "11:00"
    E dentro de "#new_turnstile" preencho o campo "Fechamento" com "14:00"
    E dentro de "#new_turnstile" clico no botão "Salvar"
    Então o elemento "#flash-notice" deve ter o texto "Catraca cadastrada com sucesso"
    E o elemento "#horario-catraca-ru-darcy-ribeiro--cat-01" deve ter o texto "11:00 às 14:00"

  @triste @cadastro @horario @validacao
  Esquema do Cenário: Rejeitar catraca com abertura igual ou posterior ao fechamento
    Dado que estou autenticado como "Administrador"
    E estou na página "Gestão de Restaurantes e Catracas"
    E a validação nativa do navegador está desativada no formulário "#new_turnstile"
    Quando clico no botão "+ Associar Nova Catraca"
    E dentro de "#new_turnstile" preencho o campo "Código" com "CAT-01"
    E dentro de "#new_turnstile" seleciono "RU Darcy Ribeiro" no campo "Restaurante"
    E dentro de "#new_turnstile" seleciono "Inativa" no campo "Status"
    E dentro de "#new_turnstile" preencho o campo "Abertura" com "<abertura>"
    E dentro de "#new_turnstile" preencho o campo "Fechamento" com "<fechamento>"
    E dentro de "#new_turnstile" clico no botão "Salvar"
    Então o elemento "#flash-alert" deve ter o texto "<mensagem>"
    E não deve existir nenhuma catraca no restaurante "RU Darcy Ribeiro"

    Exemplos:
      | abertura | fechamento | mensagem                                                                    |
      | 14:00    | 11:00      | O horário de abertura da catraca deve ser anterior ao horário de fechamento |
      | 11:00    | 11:00      | O horário de abertura da catraca deve ser anterior ao horário de fechamento |

  @triste @cadastro @horario @validacao
  Esquema do Cenário: Rejeitar horário de catraca inválido ou preenchido pela metade
    Dado que estou autenticado como "Administrador"
    E estou na página "Gestão de Restaurantes e Catracas"
    E a validação nativa do navegador está desativada no formulário "#new_turnstile"
    Quando clico no botão "+ Associar Nova Catraca"
    E dentro de "#new_turnstile" preencho o campo "Código" com "CAT-01"
    E dentro de "#new_turnstile" seleciono "RU Darcy Ribeiro" no campo "Restaurante"
    E dentro de "#new_turnstile" seleciono "Inativa" no campo "Status"
    E dentro de "#new_turnstile" preencho o campo "Abertura" com "<abertura>"
    E dentro de "#new_turnstile" preencho o campo "Fechamento" com "<fechamento>"
    E dentro de "#new_turnstile" clico no botão "Salvar"
    Então o elemento "#flash-alert" deve ter o texto "<mensagem>"
    E não deve existir nenhuma catraca no restaurante "RU Darcy Ribeiro"

    Exemplos:
      | abertura | fechamento | mensagem                                                         |
      | 25:99    | 14:00      | Horário de abertura da catraca é inválido                        |
      | 11:00    |            | Informe os horários de abertura e fechamento da catraca juntos   |

  @triste @cadastro @unicidade
  Esquema do Cenário: Rejeitar código de catraca já existente no mesmo restaurante
    Dado que estou autenticado como "Administrador"
    E existe a catraca "CAT-01" no restaurante "RU Darcy Ribeiro" com:
      | status | Ativa |
    E estou na página "Gestão de Restaurantes e Catracas"
    E a validação nativa do navegador está desativada no formulário "#new_turnstile"
    Quando clico no botão "+ Associar Nova Catraca"
    E dentro de "#new_turnstile" preencho o campo "Código" com "<codigo>"
    E dentro de "#new_turnstile" seleciono "RU Darcy Ribeiro" no campo "Restaurante"
    E dentro de "#new_turnstile" seleciono "Inativa" no campo "Status"
    E dentro de "#new_turnstile" clico no botão "Salvar"
    Então o elemento "#flash-alert" deve ter o texto "Já existe uma catraca com este código neste restaurante"
    E deve existir exatamente 1 catraca no restaurante "RU Darcy Ribeiro"

    Exemplos:
      | codigo |
      | CAT-01 |
      | cat-01 |

  @feliz @cadastro @unicidade
  Cenário: Aceitar o mesmo código de catraca em restaurantes diferentes
    Dado que estou autenticado como "Administrador"
    E existe o restaurante "RU Gama"
    E existe a catraca "CAT-01" no restaurante "RU Darcy Ribeiro" com:
      | status | Ativa |
    E estou na página "Gestão de Restaurantes e Catracas"
    Quando clico no botão "+ Associar Nova Catraca"
    E dentro de "#new_turnstile" preencho o campo "Código" com "CAT-01"
    E dentro de "#new_turnstile" seleciono "RU Gama" no campo "Restaurante"
    E dentro de "#new_turnstile" seleciono "Ativa" no campo "Status"
    E dentro de "#new_turnstile" clico no botão "Salvar"
    Então o elemento "#flash-notice" deve ter o texto "Catraca cadastrada com sucesso"
    E o elemento "#catraca-ru-gama--cat-01" deve existir na página
    E o elemento "#catraca-ru-darcy-ribeiro--cat-01" deve existir na página

  @triste @cadastro @status
  Cenário: Não cadastrar catraca Ativa em restaurante Inativo
    Dado que estou autenticado como "Administrador"
    E existe o restaurante "RU Gama" com:
      | status | Inativo |
    E estou na página "Gestão de Restaurantes e Catracas"
    E a validação nativa do navegador está desativada no formulário "#new_turnstile"
    Quando clico no botão "+ Associar Nova Catraca"
    E dentro de "#new_turnstile" preencho o campo "Código" com "CAT-09"
    E dentro de "#new_turnstile" seleciono "RU Gama" no campo "Restaurante"
    E dentro de "#new_turnstile" seleciono "Ativa" no campo "Status"
    E dentro de "#new_turnstile" clico no botão "Salvar"
    Então o elemento "#flash-alert" deve ter o texto "Não é possível ativar a catraca porque o restaurante está Inativo"
    E o elemento "#catraca-ru-gama--cat-09" não deve existir na página

  @feliz @edicao
  Cenário: Editar o código de uma catraca
    Dado que estou autenticado como "Administrador"
    E existe a catraca "CAT-01" no restaurante "RU Darcy Ribeiro" com:
      | status | Inativa |
    E estou na página "Gestão de Restaurantes e Catracas"
    Quando clico em "#editar-catraca-ru-darcy-ribeiro--cat-01"
    E dentro do formulário de edição da catraca "CAT-01" do restaurante "RU Darcy Ribeiro" preencho o campo "Código" com "CAT-10"
    E dentro do formulário de edição da catraca "CAT-01" do restaurante "RU Darcy Ribeiro" clico no botão "Salvar"
    Então o elemento "#flash-notice" deve ter o texto "Catraca atualizada com sucesso"
    E o elemento "#status-catraca-ru-darcy-ribeiro--cat-10" deve ter o texto exato "Inativa"

  @triste @edicao @status
  Cenário: Não ativar catraca em manutenção de restaurante Inativo
    Dado que estou autenticado como "Administrador"
    E existe o restaurante "RU Gama" com:
      | status | Inativo |
    E existe a catraca "CAT-01" no restaurante "RU Gama" com:
      | status | Em Manutenção |
    E estou na página "Gestão de Restaurantes e Catracas"
    Quando clico em "#editar-catraca-ru-gama--cat-01"
    E dentro do formulário de edição da catraca "CAT-01" do restaurante "RU Gama" seleciono "Ativa" no campo "Status"
    E dentro do formulário de edição da catraca "CAT-01" do restaurante "RU Gama" clico no botão "Salvar"
    Então o elemento "#flash-alert" deve ter o texto "Não é possível ativar a catraca porque o restaurante está Inativo"
    E o elemento "#status-catraca-ru-gama--cat-01" deve ter o texto exato "Em Manutenção"

  @triste @edicao @integridade
  Cenário: Não renomear catraca que já tem registros de acesso
    Dado que estou autenticado como "Administrador"
    E existe a catraca "CAT-01" no restaurante "RU Darcy Ribeiro" com:
      | status | Inativa |
    E existem os acessos na catraca "CAT-01" do restaurante "RU Darcy Ribeiro":
      | data       | hora  | matricula | resultado |
      | 10/09/2026 | 11:45 | 241012345 | Liberado  |
    E estou na página "Gestão de Restaurantes e Catracas"
    Quando clico em "#editar-catraca-ru-darcy-ribeiro--cat-01"
    E dentro de "#editar-form-catraca-ru-darcy-ribeiro--cat-01" preencho o campo "Código" com "CAT-10"
    E dentro de "#editar-form-catraca-ru-darcy-ribeiro--cat-01" clico no botão "Salvar"
    Então o elemento "#flash-alert" deve ter o texto "Não é possível alterar o código ou o restaurante"
    E o elemento "#catraca-ru-darcy-ribeiro--cat-01" deve existir na página
    E o elemento "#catraca-ru-darcy-ribeiro--cat-10" não deve existir na página

  @triste @edicao @integridade
  Cenário: Não mover para outro restaurante uma catraca que já tem registros de acesso
    Dado que estou autenticado como "Administrador"
    E existe o restaurante "RU Gama"
    E existe a catraca "CAT-01" no restaurante "RU Darcy Ribeiro" com:
      | status | Inativa |
    E existem os acessos na catraca "CAT-01" do restaurante "RU Darcy Ribeiro":
      | data       | hora  | matricula | resultado |
      | 10/09/2026 | 11:45 | 241012345 | Liberado  |
    E estou na página "Gestão de Restaurantes e Catracas"
    Quando clico em "#editar-catraca-ru-darcy-ribeiro--cat-01"
    E dentro de "#editar-form-catraca-ru-darcy-ribeiro--cat-01" seleciono "RU Gama" no campo "Restaurante"
    E dentro de "#editar-form-catraca-ru-darcy-ribeiro--cat-01" clico no botão "Salvar"
    Então o elemento "#flash-alert" deve ter o texto "Não é possível alterar o código ou o restaurante"
    E o elemento "#catraca-ru-darcy-ribeiro--cat-01" deve existir na página
    E o elemento "#catraca-ru-gama--cat-01" não deve existir na página

  @feliz @status
  Esquema do Cenário: Mudar o status de uma catraca no mesmo restaurante Ativo
    Dado que estou autenticado como "Administrador"
    E existe a catraca "CAT-01" no restaurante "RU Darcy Ribeiro" com:
      | status | <status_inicial> |
    E estou na página "Gestão de Restaurantes e Catracas"
    E a validação nativa do navegador está desativada no formulário de edição da catraca "CAT-01" do restaurante "RU Darcy Ribeiro"
    Quando clico em "#editar-catraca-ru-darcy-ribeiro--cat-01"
    E dentro do formulário de edição da catraca "CAT-01" do restaurante "RU Darcy Ribeiro" seleciono "<status_final>" no campo "Status"
    E dentro do formulário de edição da catraca "CAT-01" do restaurante "RU Darcy Ribeiro" clico no botão "Salvar"
    Então o elemento "#flash-notice" deve ter o texto "Catraca atualizada com sucesso"
    E o elemento "#status-catraca-ru-darcy-ribeiro--cat-01" deve ter o texto exato "<status_final>"

    Exemplos:
      | status_inicial | status_final  |
      | Ativa          | Em Manutenção |
      | Em Manutenção  | Ativa         |

  @feliz @remocao
  Cenário: Remover catraca Inativa após aceitar a confirmação
    Dado que estou autenticado como "Administrador"
    E existe a catraca "CAT-01" no restaurante "RU Darcy Ribeiro" com:
      | status | Inativa |
    E estou na página "Gestão de Restaurantes e Catracas"
    Quando clico em "#remover-catraca-ru-darcy-ribeiro--cat-01" e aceito a confirmação "Deseja realmente remover a catraca?"
    Então o elemento "#flash-notice" deve ter o texto "Catraca removida com sucesso"
    E o elemento "#catraca-ru-darcy-ribeiro--cat-01" não deve existir na página

  @triste @remocao
  Cenário: Não remover catraca Ativa
    Dado que estou autenticado como "Administrador"
    E existe a catraca "CAT-01" no restaurante "RU Darcy Ribeiro" com:
      | status | Ativa |
    E estou na página "Gestão de Restaurantes e Catracas"
    Quando clico em "#remover-catraca-ru-darcy-ribeiro--cat-01"
    Então o elemento "#flash-alert" deve ter o texto "Não é possível remover uma catraca Ativa. Inative a catraca antes de removê-la"
    E o elemento "#status-catraca-ru-darcy-ribeiro--cat-01" deve ter o texto exato "Ativa"

  @triste @remocao
  Cenário: Não remover catraca que tem responsável
    Dado que estou autenticado como "Administrador"
    E existe a catraca "CAT-01" no restaurante "RU Darcy Ribeiro" com:
      | status      | Inativa       |
      | responsavel | Carlos Mendes |
    E estou na página "Gestão de Restaurantes e Catracas"
    Quando clico em "#remover-catraca-ru-darcy-ribeiro--cat-01"
    Então o elemento "#flash-alert" deve ter o texto "Não é possível remover uma catraca com responsável ou registros de acesso. Ela só pode ficar inativa"
    E o elemento "#catraca-ru-darcy-ribeiro--cat-01" deve existir na página

  @triste @autorizacao @rack_test
  Esquema do Cenário: Funcionário não gerencia catracas
    Dado que existe a catraca "CAT-01" no restaurante "RU Darcy Ribeiro" com:
      | status | Inativa |
    E estou autenticado como "Funcionário"
    Quando envio uma requisição "<metodo>" para a rota "<rota>" da catraca "CAT-01" do restaurante "RU Darcy Ribeiro"
    Então a resposta deve ter status 403
    E o elemento "#flash-alert" deve ter o texto "Acesso negado: apenas o Administrador pode realizar esta ação"
    E a catraca "CAT-01" do restaurante "RU Darcy Ribeiro" deve permanecer inalterada

    Exemplos:
      | metodo | rota    |
      | GET    | nova    |
      | POST   | criar   |
      | GET    | editar  |
      | PATCH  | editar  |
      | DELETE | remover |
