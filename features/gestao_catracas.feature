# language: pt
Funcionalidade: Gestão de Catracas
  Como administrador
  Eu quero cadastrar, editar, remover e alterar o status das catracas de cada restaurante
  Para que os funcionários possam selecionar catracas em condições de uso na Aplicação de Controle

  Contexto:
    Dado que estou logado como "Administrador"
    E estou na página de Gestão de Restaurantes e Catracas

  @mvp @feliz
  Cenário: Cadastrar catraca vinculada a um restaurante (Caminho Feliz)
    Dado que existe o restaurante "RU Darcy Ribeiro" com status "Ativo"
    Quando clico no botão "Nova catraca"
    E preencho o código "CAT-01", seleciono o restaurante "RU Darcy Ribeiro" e o status "Ativa"
    E clico no botão "Salvar"
    Então o sistema deve exibir a mensagem "Catraca cadastrada com sucesso"
    E a catraca "CAT-01" deve aparecer no restaurante "RU Darcy Ribeiro" com o status "Ativa"

  @mvp @triste
  Esquema do Cenário: Cadastrar catraca com código vazio ou duplicado no mesmo restaurante (Caminho Triste)
    Dado que existe o restaurante "RU Darcy Ribeiro" com status "Ativo"
    E existe a catraca "CAT-01" com status "Ativa" no restaurante "RU Darcy Ribeiro"
    Quando clico no botão "Nova catraca"
    E preencho o código "<codigo>", seleciono o restaurante "RU Darcy Ribeiro" e o status "Inativa"
    E clico no botão "Salvar"
    Então o sistema deve exibir a mensagem de erro "<mensagem>"
    E deve existir apenas 1 catraca no restaurante "RU Darcy Ribeiro"

    Exemplos:
      | codigo | mensagem                                                |
      |        | Código da catraca é obrigatório                         |
      | CAT-01 | Já existe uma catraca com este código neste restaurante |

  @mvp @feliz
  Cenário: Editar catraca e mudar o status para Em Manutenção (Caminho Feliz)
    Dado que existe o restaurante "RU Darcy Ribeiro" com status "Ativo"
    E existe a catraca "CAT-01" com status "Ativa" no restaurante "RU Darcy Ribeiro"
    Quando clico no botão "Editar" da catraca "CAT-01" do restaurante "RU Darcy Ribeiro"
    E seleciono o status "Em Manutenção"
    E clico no botão "Salvar"
    Então o sistema deve exibir a mensagem "Catraca atualizada com sucesso"
    E a catraca "CAT-01" deve ter o status "Em Manutenção"

  @mvp @triste
  Cenário: Ativar catraca de restaurante Inativo (Caminho Triste)
    Dado que existe o restaurante "RU Darcy Ribeiro" com status "Inativo"
    E existe a catraca "CAT-01" com status "Inativa" no restaurante "RU Darcy Ribeiro"
    Quando altero o status da catraca "CAT-01" do restaurante "RU Darcy Ribeiro" para "Ativa"
    Então o sistema deve exibir a mensagem de erro "Não é possível ativar a catraca porque o restaurante está Inativo"
    E a catraca "CAT-01" deve continuar com o status "Inativa"

  @mvp @feliz
  Cenário: Remover catraca Inativa com confirmação (Caminho Feliz)
    Dado que existe o restaurante "RU Darcy Ribeiro" com status "Ativo"
    E existe a catraca "CAT-01" com status "Inativa" no restaurante "RU Darcy Ribeiro"
    Quando clico no botão "Remover" da catraca "CAT-01" do restaurante "RU Darcy Ribeiro"
    Então o sistema deve pedir confirmação com a mensagem "Deseja realmente remover a catraca?"
    Quando clico no botão "Confirmar"
    Então o sistema deve exibir a mensagem "Catraca removida com sucesso"
    E não deve existir a catraca "CAT-01" no restaurante "RU Darcy Ribeiro"

  @mvp @triste
  Cenário: Remover catraca Ativa (Caminho Triste)
    Dado que existe o restaurante "RU Darcy Ribeiro" com status "Ativo"
    E existe a catraca "CAT-01" com status "Ativa" no restaurante "RU Darcy Ribeiro"
    Quando clico no botão "Remover" da catraca "CAT-01" do restaurante "RU Darcy Ribeiro"
    Então o sistema deve exibir a mensagem de erro "Não é possível remover uma catraca Ativa. Inative a catraca antes de removê-la"
    E a catraca "CAT-01" deve continuar no restaurante "RU Darcy Ribeiro" com o status "Ativa"
