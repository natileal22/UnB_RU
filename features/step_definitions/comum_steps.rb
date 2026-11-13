SENHA_DE_TESTE = "SenhaForte123".freeze

Dado(/^(?:que )?existe o restaurante "([^"]*)" com status "([^"]*)"$/) do |nome, status|
  Restaurant.create!(name: nome, status: codigo_de_status(status))
end

Dado(/^(?:que )?existe a catraca "([^"]*)" com status "([^"]*)" no restaurante "([^"]*)"$/) do |codigo, status, nome|
  restaurante = Restaurant.find_or_create_by!(name: nome)
  Catraca.create!(restaurant: restaurante, codigo: codigo, status: codigo_de_status(status))
end

# Funcionário/administrador entra pela autenticação do operador (issue do Pedro);
# estudante entra pelo login de /login.
Dado(/^(?:que )?estou logado como "([^"]*)"$/) do |perfil_feature|
  perfil = perfil_do_model(perfil_feature)
  @usuario_logado = User.create!(name: "Usuário #{perfil_feature}", matricula: proxima_matricula(perfil),
                                 password: SENHA_DE_TESTE, perfil: perfil)
  if @usuario_logado.operador_autorizado?
    visit operador_entrar_path
    fill_in "Matrícula SIAPE ou Usuário SIGAA / gov.br", with: @usuario_logado.matricula
    fill_in "Senha de Acesso", with: SENHA_DE_TESTE
    find("button[type=submit]").click
  else
    visit login_path
    fill_in "Matrícula", with: @usuario_logado.matricula
    fill_in "Senha", with: SENHA_DE_TESTE
    click_button "Entrar"
  end
end

Dado(/^(?:que )?não estou autenticado no sistema$/) do
  # Nenhuma ação: o navegador do teste começa sem sessão.
end

# "o sistema deve exibir a mensagem de erro {string}" está definido em autenticacao_funcionario_steps.rb (Pedro).

Então("o sistema deve exibir a mensagem {string}") do |mensagem|
  expect(page).to have_content(mensagem)
end
