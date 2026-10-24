Funcionalidade: Cardápio da refeição atual
  Como estudante
  Eu quero poder ver o cardápio da refeição que esteja sendo servida agora. 
  Incluindo as opções padrão, ovolactovegetariano e vegetariano estrito.

  Cenário: Visualização do cardápio no horário de atendimento (Cenário Feliz)
    Dado que o horário do sistema é "12:00"
    E a refeição "Almoço" está em andamento
    E existe um cardápio cadastrado para a data de hoje e refeição "Almoço" com as opções:
      | Tipo                  | Item                    |
      | Padrão                | Strogonoff de Frango    |
      | Ovolactovegetariano   | Omelete de Queijo       |
      | Vegetariano Estrito   | Strogonoff de Cogumelos |
    Quando o estudante acessa a página do cardápio atual
    Então o sistema deve exibir a refeição atual como "Almoço"
    E deve apresentar as três opções: Padrão, Ovolactovegetariano, Vegetariano Estrito

Cenário: Cardápio da refeição atual ainda não cadastrado no banco (Cenário Triste)
    Dado que o horário do sistema é "18:00"
    E a refeição "Jantar" está em andamento
    E não existe um cardápio cadastrado para o jantar na data de hoje
    Quando o estudante acessa a página do cardápio atual
    Então o sistema deve exibir a mensagem "O cardápio para o Jantar de hoje ainda não foi disponibilizado"

  Cenário: Acesso à página fora do horário de funcionamento do RU (Cenário Triste)
    Dado que o horário do sistema é "15:30"
    E nenhuma refeição está sendo servida no momento
    Quando o estudante acessa a página do cardápio atual
    Então o sistema deve exibir a mensagem "Nenhuma refeição está sendo servida neste horário"
    E deve informar o horário do próximo serviço disponível ("Jantar às 17:00")

 