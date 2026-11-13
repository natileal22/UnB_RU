# frozen_string_literal: true
# rubocop:disable Naming/AsciiIdentifiers

Dado('que o funcionário possui uma conta ativa no sistema') do
  User.find_or_create_by!(matricula: '1234567') do |u|
    u.nome = 'Operador Teste 1'
    u.password = 'SenhaCorreta123'
    u.perfil = 'funcionario'
  end

  User.find_or_create_by!(matricula: '4120918') do |u|
    u.nome = 'Operador Teste 2'
    u.password = 'JnL8osgaWJNdfd'
    u.perfil = 'funcionario'
  end
end

Dado('que o usuário não está cadastrado como funcionário') do
  User.where(matricula: '0101010').destroy_all
end

Dado('está na página de autenticação do operador') do
  visit operador_entrar_path
end

Dado('que o funcionário está na página de autenticação do operador') do
  visit operador_entrar_path
end

Quando('ele preenche a credencial {string} e a senha {string}') do |matricula, senha|
  fill_in 'matricula', with: matricula
  fill_in 'senha', with: senha
end

Quando('ele preenche a credencial {string}') do |matricula|
  fill_in 'matricula', with: matricula
end

Quando('insere a senha incorreta {string}') do |senha|
  fill_in 'senha', with: senha
end

Quando('clica no botão {string}') do |texto_botao|
  click_button texto_botao
end

Quando('ele tenta clicar no botão {string} sem preencher o usuário e a senha') do |texto_botao|
  fill_in 'matricula', with: ''
  fill_in 'senha', with: ''
  click_button texto_botao
end

Então('o sistema deve autenticar a sessão com sucesso') do
  expect(page).to have_no_content('Credenciais inválidas')
end

Então('redirecionar o funcionário para a página de Gestão de Restaurantes e Catracas') do
  expect(page).to have_current_path(admin_restaurantes_path)
  expect(page).to have_content('Gestão de Restaurantes e Catracas')
end

Então('o sistema deve exibir a mensagem de erro {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('o sistema deve exibir um alerta {string}') do |alerta|
  expect(page).to have_content(alerta)
end

Então('a sessão não deve ser iniciada') do
  expect(page).not_to have_current_path(admin_restaurantes_path)
end

Então('o usuário deve permanecer na página de autenticação do operador') do
  expect(page).to have_current_path(operador_entrar_path)
  expect(page).to have_content('Autenticação do Operador')
end
