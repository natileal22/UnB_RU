Dado('que o estudante está cadastrado no sistema do Ru') do
  @estudante = User.create!(name: 'Estudante Teste', matricula: '231000001', password: 'senha123', saldo: 100)
  @saldo_inicial = @estudante.saldo
  visit login_path
  fill_in 'Matrícula', with: @estudante.matricula
  fill_in 'Senha', with: 'senha123'
  click_button 'Entrar'
end

Dado('está na página de Recarga de Saldo') do
  visit nova_recarga_path
  expect(page).to have_content('Recarga de Saldo')
end

Quando(/^ele seleciona o método de pagamento (PIX|Cartão de Crédito)$/) do |metodo|
  choose(metodo)
end

Quando(/^(?:ele )?insere o valor de (-?\d+(?:\.\d+)?) reais$/) do |valor|
  fill_in 'Valor (R$)', with: valor
end

Quando('preenche os dados do cartão corretamente') do
  preencher_cartao('4111 1111 1111 1111')
end

Quando('preenche os dados de um cartão sem limite') do
  preencher_cartao(GatewayCartao::CARTOES_SEM_LIMITE.first)
end

Quando(/^(?:confirma|tenta confirmar) a transação$/) do
  click_button 'Confirmar recarga'
end

Então('o sistema deve gerar o QR Code de pagamento') do
  expect(page).to have_content('QR Code de pagamento')
  expect(page).to have_css('#codigo-pix', text: /\APIX-UNBRU-/)
end

Então('após a confirmação do pagamento, o saldo da conta deve ser atualizado com mais {float} reais') do |valor|
  click_button 'Já paguei'
  expect(@estudante.reload.saldo).to eq(@saldo_inicial + valor.to_d)
end

Então('o sistema deve aprovar a compra') do
  expect(page).to have_content('Compra aprovada')
end

Então('o sistema deve recusar a compra') do
  expect(page).to have_content('Compra recusada')
end

Então('o saldo da conta deve ser atualizado com mais {float} reais') do |valor|
  expect(@estudante.reload.saldo).to eq(@saldo_inicial + valor.to_d)
end

Então('o saldo da conta não deve ser atualizado com mais {float} reais') do |_valor|
  expect(@estudante.reload.saldo).to eq(@saldo_inicial)
end

Então(/^o sistema deve exibir uma mensagem de erro (.+)$/) do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('a transação não deve ser processada') do
  expect(@estudante.recargas.count).to eq(0)
  expect(@estudante.reload.saldo).to eq(@saldo_inicial)
end

def preencher_cartao(numero)
  fill_in 'Número do cartão', with: numero
  fill_in 'Nome impresso no cartão', with: 'ESTUDANTE TESTE'
  fill_in 'Validade (MM/AA)', with: '12/30'
  fill_in 'CVV', with: '123'
end