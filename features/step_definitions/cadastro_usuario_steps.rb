Dado("que o estudante está na página de cadastro de usuário") do
  visit new_user_path
end

Dado("o estudante está na página de cadastro de usuário") do
  visit new_user_path
end

Quando("ele preenche o nome {string}") do |nome|
  fill_in "Nome completo", with: nome
end

Quando("informa a matrícula {string}") do |matricula|
  @matricula_cadastro = matricula
  fill_in "Matrícula", with: matricula
end

Quando("informa a senha {string}") do |senha|
  fill_in "Senha", with: senha
end

Quando("ele clica no botão {string} sem preencher os campos obrigatórios") do |botao|
  click_button botao
end

Então("o sistema deve criar a conta do estudante com sucesso") do
  expect(User.find_by(matricula: @matricula_cadastro)).to be_present
end

Então("deve exibir a mensagem {string}") do |mensagem|
  expect(page).to have_content(mensagem)
end

Então("deve redirecionar o estudante para a página de autenticação") do
  expect(page).to have_current_path(login_path)
end

Então("a conta do estudante não deve ser criada") do
  expect(User.find_by(matricula: @matricula_cadastro)).to be_nil
end

Então("o estudante deve permanecer na página de cadastro de usuário") do
  expect(page).to have_current_path(users_path)
end

Dado("que já existe uma conta cadastrada para a matrícula {string}") do |matricula|
  User.create!(name: "Estudante existente", matricula: matricula, password: "SenhaForte123")
end

Então("uma nova conta não deve ser criada") do
  expect(User.where(matricula: @matricula_cadastro).count).to eq(1)
end
