Funcionalidade: Cadastro de Usuário
  Como estudante
  Eu quero me cadastrar no sistema utilizando minha matrícula
  Para que eu possa criar minha conta de acesso ao RU

  Esquema do Cenário: Cadastro bem-sucedido com matrícula válida (Happy Path)
    # Dado que o estudante possui uma matrícula ativa na UnB
    Dado que o estudante está na página de cadastro de usuário
    Quando ele preenche o nome "<nome>"
    E informa a matrícula "<matricula>"
    # E informa o e-mail "<email>"
    E informa a senha "<senha>"
    # E confirma a senha "<confirmacao_senha>"
    E clica no botão "Cadastrar"
    Então o sistema deve criar a conta do estudante com sucesso
    E deve exibir a mensagem "Cadastro realizado com sucesso"
    E deve redirecionar o estudante para a página de autenticação

    Exemplos:
        | nome           | matricula | email                | senha           | confirmacao_senha |
        | Ana Silva      | 123456789 | ana.silva@unb.br     | SenhaForte123   | SenhaForte123     |
        | Bruno Oliveira | 202012345 | bruno.oliveira@unb.br | AcessoRU456     | AcessoRU456       |

  Cenário: Tentativa de cadastro sem preencher campos obrigatórios (Sad Path)
    Dado que o estudante está na página de cadastro de usuário
    Quando ele clica no botão "Cadastrar" sem preencher os campos obrigatórios
    Então o sistema deve exibir um alerta "Preencha todos os campos obrigatórios"
    E a conta do estudante não deve ser criada
    E o estudante deve permanecer na página de cadastro de usuário

  Esquema do Cenário: Tentativa de cadastro com matrícula inválida (Sad Path)
    Dado que o estudante está na página de cadastro de usuário
    Quando ele preenche o nome "<nome>"
    E informa a matrícula "<matricula>"
    # E informa o e-mail "<email>"
    E informa a senha "<senha>"
    # E confirma a senha "<confirmacao_senha>"
    E clica no botão "Cadastrar"
    Então o sistema deve exibir a mensagem de erro "Matrícula inválida"
    E a conta do estudante não deve ser criada

    Exemplos:
        | nome      | matricula | email           | senha         | confirmacao_senha |
        | Ana Silva | 123        | ana@unb.br      | SenhaForte123 | SenhaForte123     |
        | Ana Silva | 999999999 | ana@unb.br      | SenhaForte123 | SenhaForte123     |

  Cenário: Tentativa de cadastro com matrícula já utilizada (Sad Path)
    Dado que já existe uma conta cadastrada para a matrícula "123456789"
    E o estudante está na página de cadastro de usuário
    Quando ele preenche o nome "Ana Silva"
    E informa a matrícula "123456789"
    # E informa o e-mail "ana.nova@unb.br"
    E informa a senha "SenhaForte123"
    # E confirma a senha "SenhaForte123"
    E clica no botão "Cadastrar"
    Então o sistema deve exibir a mensagem de erro "Matrícula já cadastrada"
    E uma nova conta não deve ser criada

#  Cenário: Tentativa de cadastro com senhas diferentes (Sad Path)
#    Dado que o estudante possui uma matrícula ativa na UnB
#    E está na página de cadastro de usuário
#    Quando ele preenche o nome "Ana Silva"
#    E informa a matrícula "123456789"
#    E informa o e-mail "ana.silva@unb.br"
#    E informa a senha "SenhaForte123"
#    E confirma a senha "SenhaDiferente456"
#    E clica no botão "Cadastrar"
#    Então o sistema deve exibir a mensagem de erro "As senhas não coincidem"
#    E a conta do estudante não deve ser criada