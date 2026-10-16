# language: pt
Funcionalidade: Gestão de Restaurantes
  Como administrador
  Eu quero cadastrar, editar, remover e alterar o status de restaurantes universitários
  Para que os funcionários possam selecioná-los na Aplicação de Controle

  Contexto:
    Dado que estou logado como "Administrador"
    E estou na página de Gestão de Restaurantes e Catracas

  @mvp @feliz
  Esquema do Cenário: Cadastrar restaurante com dados válidos (Caminho Feliz)
    Quando clico no botão "Novo restaurante"
    E preencho o nome "RU Darcy Ribeiro", a localização "Campus Darcy Ribeiro" e a capacidade "<capacidade>"
    E preencho o horário de abertura "11:00" e o horário de fechamento "14:00"
    E clico no botão "Salvar"
    Então o sistema deve exibir a mensagem "Restaurante cadastrado com sucesso"
    E o restaurante "RU Darcy Ribeiro" deve aparecer na lista com o status "Ativo"

    Exemplos:
      | capacidade |
      | 1          |
      | 500        |
      | 5000       |

  @mvp @triste
  Esquema do Cenário: Cadastrar restaurante com dados inválidos (Caminho Triste)
    Quando clico no botão "Novo restaurante"
    E preencho o nome "<nome>", a localização "Campus Darcy Ribeiro" e a capacidade "<capacidade>"
    E preencho o horário de abertura "<abertura>" e o horário de fechamento "<fechamento>"
    E clico no botão "Salvar"
    Então o sistema deve exibir a mensagem de erro "<mensagem>"
    E nenhum restaurante deve ser cadastrado

    Exemplos:
      | nome             | capacidade | abertura | fechamento | mensagem                                                          |
      | RU Darcy Ribeiro | 0          | 11:00    | 14:00      | Capacidade inválida: informe um número inteiro entre 1 e 5000     |
      | RU Darcy Ribeiro | 5001       | 11:00    | 14:00      | Capacidade inválida: informe um número inteiro entre 1 e 5000     |
      | RU Darcy Ribeiro | abc        | 11:00    | 14:00      | Capacidade inválida: informe um número inteiro entre 1 e 5000     |
      |                  | 500        | 11:00    | 14:00      | Nome do restaurante é obrigatório                                 |
      | RU Darcy Ribeiro | 500        | 14:00    | 11:00      | O horário de abertura deve ser anterior ao horário de fechamento  |

  @mvp @triste
  Cenário: Cadastrar restaurante com nome já existente (Caminho Triste)
    Dado que existe o restaurante "RU Darcy Ribeiro"
    Quando clico no botão "Novo restaurante"
    E preencho o nome "RU Darcy Ribeiro", a localização "Campus Gama" e a capacidade "300"
    E preencho o horário de abertura "11:00" e o horário de fechamento "14:00"
    E clico no botão "Salvar"
    Então o sistema deve exibir a mensagem de erro "Já existe um restaurante com este nome"
    E deve existir apenas 1 restaurante com o nome "RU Darcy Ribeiro"

  @mvp @feliz
  Cenário: Editar os dados de um restaurante (Caminho Feliz)
    Dado que existe o restaurante "RU Darcy Ribeiro"
    Quando clico no botão "Editar" do restaurante "RU Darcy Ribeiro"
    E preencho a capacidade "800" e o horário de abertura "10:30"
    E clico no botão "Salvar"
    Então o sistema deve exibir a mensagem "Restaurante atualizado com sucesso"
    E o restaurante "RU Darcy Ribeiro" deve aparecer na lista com capacidade "800" e abertura às "10:30"

  @mvp @feliz
  Cenário: Inativar restaurante inativa as catracas Ativas e mantém as Em Manutenção (Caminho Feliz)
    Dado que existe o restaurante "RU Darcy Ribeiro" com status "Ativo"
    E existe a catraca "CAT-01" com status "Ativa" no restaurante "RU Darcy Ribeiro"
    E existe a catraca "CAT-02" com status "Em Manutenção" no restaurante "RU Darcy Ribeiro"
    Quando clico no botão "Inativar" do restaurante "RU Darcy Ribeiro"
    Então o sistema deve exibir a mensagem "Restaurante e suas catracas ativas foram inativados"
    E o restaurante "RU Darcy Ribeiro" deve ter o status "Inativo"
    E a catraca "CAT-01" deve ter o status "Inativa"
    E a catraca "CAT-02" deve continuar com o status "Em Manutenção"

  @mvp @triste
  Cenário: Remover restaurante que possui catracas vinculadas (Caminho Triste)
    Dado que existe o restaurante "RU Darcy Ribeiro"
    E existe a catraca "CAT-01" com status "Inativa" no restaurante "RU Darcy Ribeiro"
    Quando clico no botão "Remover" do restaurante "RU Darcy Ribeiro"
    Então o sistema deve exibir a mensagem de erro "Não é possível remover um restaurante com catracas vinculadas. Remova as catracas antes ou apenas inative o restaurante"
    E o restaurante "RU Darcy Ribeiro" deve continuar existindo

  @mvp @triste
  Cenário: Funcionário sem permissão para gerenciar restaurantes (Caminho Triste)
    Dado que existe o restaurante "RU Darcy Ribeiro"
    Mas estou logado como "Funcionário" e não como "Administrador"
    Quando tento acessar diretamente o endereço de cadastro de restaurante
    Então o sistema deve exibir a mensagem de erro "Acesso negado: apenas o Administrador pode realizar esta ação"
    E nenhum restaurante deve ser cadastrado
