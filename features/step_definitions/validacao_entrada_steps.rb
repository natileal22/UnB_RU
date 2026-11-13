Dado(/^(?:que )?o preço da refeição é "([^"]*)"$/) do |preco|
  expect(ValidacaoEntrada::PRECO).to eq(valor_em_reais(preco))
end

Dado(/^(?:que )?o estudante de matrícula "([^"]*)" está cadastrado no sistema do RU$/) do |matricula|
  @estudante = User.create!(name: "Estudante #{matricula}", matricula: matricula,
                            password: SENHA_DE_TESTE, perfil: "estudante")
end

Dado(/^(?:que )?o estudante de matrícula "([^"]*)" não está cadastrado no sistema do RU$/) do |matricula|
  expect(User.find_by(matricula: matricula)).to be_nil
end

Dado(/^(?:que )?o estudante possui saldo de "([^"]*)"$/) do |saldo|
  @estudante.update!(saldo: valor_em_reais(saldo))
end

Quando("o estudante apresenta a matrícula {string} na catraca {string}") do |matricula, codigo|
  catraca = Catraca.find_by!(codigo: codigo)
  visit catraca_path(catraca)
  fill_in "Matrícula", with: matricula
  click_button "Validar entrada"
end

Então("o sistema deve liberar a catraca") do
  expect(page).to have_css(".flash-notice", text: "Entrada liberada")
end

Então("a catraca não deve ser liberada") do
  expect(page).not_to have_content("Entrada liberada")
end

Então(/^o saldo do estudante deve (?:ser|permanecer) "([^"]*)"$/) do |saldo|
  expect(@estudante.reload.saldo).to eq(valor_em_reais(saldo))
end

Então("deve ser registrado um acesso {string}") do |resultado|
  acesso = Access.order(:id).last
  expect(acesso.resultado).to eq(resultado)
  expect(acesso.motivo_negacao).to be_nil
end

Então("deve ser registrado um acesso {string} com motivo {string}") do |resultado, motivo|
  acesso = Access.order(:id).last
  expect(acesso.resultado).to eq(resultado)
  expect(acesso.motivo_negacao).to eq(motivo)
end
