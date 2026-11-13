Dado(/^(?:que )?estou na página de seleção de ponto de acesso$/) do
  visit ponto_acesso_path
end

Dado(/^(?:que )?não existe nenhum restaurante com status "([^"]*)"$/) do |status|
  expect(Restaurant.where(status: codigo_de_status(status))).to be_empty
end

Dado(/^(?:que )?o ponto de acesso está configurado para o restaurante "([^"]*)"$/) do |nome|
  visit ponto_acesso_path
  select nome, from: "Restaurante"
  click_button "Confirmar"
end

Quando(/^(?:tento )?acess(?:o|ar) a tela de seleção de ponto de acesso$/) do
  visit ponto_acesso_path
end

# Recarrega a página antes de agir: nos cenários, o restaurante é criado depois de abrir a tela.
Quando("seleciono o restaurante {string} na lista") do |nome|
  visit ponto_acesso_path
  select nome, from: "Restaurante"
end

Quando("clico no botão {string}") do |botao|
  click_button botao
end

Quando("clico no botão {string} sem selecionar nenhum restaurante") do |botao|
  visit ponto_acesso_path
  click_button botao
end

Quando("tento selecionar diretamente o restaurante {string} como ponto de acesso") do |nome|
  restaurante = Restaurant.find_by!(name: nome)
  page.driver.submit :post, ponto_acesso_path, { restaurant_id: restaurante.id }
end

Então("o restaurante {string} deve aparecer na lista de seleção") do |nome|
  expect(page).to have_select("Restaurante", with_options: [nome])
end

Então("o restaurante {string} não deve aparecer na lista de seleção") do |nome|
  expect(page).not_to have_select("Restaurante", with_options: [nome])
end

Então("devo ser direcionado para a operação do restaurante {string}") do |nome|
  expect(page).to have_current_path(operacao_path)
  expect(page).to have_css("#restaurante-em-operacao", text: nome)
end

Então("o nome {string} deve aparecer na tela de operação") do |nome|
  expect(page).to have_css("#restaurante-em-operacao", text: nome)
end

Então("o ponto de acesso não deve ser configurado") do
  visit operacao_path
  expect(page).not_to have_css("#restaurante-em-operacao")
end

Então("o sistema deve redirecionar para a página de autenticação") do
  expect(page).to have_current_path(operador_entrar_path)
end
