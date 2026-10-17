Funcionalidade: Recarga de Saldo
  Como estudante
  Eu quero adicionar créditos à minha conta via PIX ou cartão de crédito
  Para que eu tenha saldo suficiente para acessar os restaurantes da UnB

  Cenário: Recarga bem-sucedida com PIX (Caminho Feliz)
    Dado que o estudante está cadastrado no sistema do Ru 
    E está na página de Recarga de Saldo
    Quando ele seleciona o método de pagamento PIX
    E insere o valor de 30.00 reais
    E confirma a transação
    Então o sistema deve gerar o QR Code de pagamento
    E após a confirmação do pagamento, o saldo da conta deve ser atualizado com mais 30.00 reais

  Cenário: Tentativa de recarga com valor negativo ou zero (Caminho Triste)
    Dado que o estudante está cadastrado no sistema do Ru 
    E está na página de Recarga de Saldo
    Quando ele insere o valor de -10.00 reais
    E tenta confirmar a transação
    Então o sistema deve exibir uma mensagem de erro Valor de recarga inválido
    E a transação não deve ser processada

  Cenário: Recarga bem-sucedida com Cartão de Crédito (Caminho Feliz)
    Dado que o estudante está cadastrado no sistema do Ru 
    E está na página de Recarga de Saldo
    Quando ele seleciona o método de pagamento Cartão de Crédito
    E insere o valor de 80.00 reais
    E preenche os dados do cartão corretamente
    E confirma a transação
    Então o sistema deve aprovar a compra
    E o saldo da conta deve ser atualizado com mais 80.00 reais

  Cenário: Tentativa de recarga com Cartão de Crédito sem limite (Caminho Triste)
    Dado que o estudante está cadastrado no sistema do Ru 
    E está na página de Recarga de Saldo
    Quando ele seleciona o método de pagamento Cartão de Crédito
    E insere o valor de 80.00 reais
    E preenche os dados do cartão corretamente
    E confirma a transação
    Mas está sem limite no cartão
    Então o sistema deve recusar a compra
    E o saldo da conta não deve ser atualizado com mais 80.00 reais
