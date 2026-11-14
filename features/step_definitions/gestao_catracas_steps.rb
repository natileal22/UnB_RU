# frozen_string_literal: true

# rubocop:disable Naming/AsciiIdentifiers
def formulario_da_catraca(codigo, nome_restaurante)
  "#editar-form-catraca-#{nome_restaurante.parameterize}--#{codigo.parameterize}"
end

def caminho_da_catraca(rota, metodo, catraca)
  case rota
  when 'nova' then new_admin_catraca_path
  when 'criar' then admin_catracas_path
  when 'editar' then metodo == 'GET' ? edit_admin_catraca_path(catraca) : admin_catraca_path(catraca)
  else admin_catraca_path(catraca)
  end
end

Dado('existe o funcionário {string}') do |nome|
  User.create!(nome: nome, matricula: proxima_matricula('funcionario'), password: SENHA_DE_TESTE,
               perfil: 'funcionario')
end

Dado('existe o estudante {string}') do |nome|
  User.create!(nome: nome, matricula: proxima_matricula('estudante'), password: SENHA_DE_TESTE, perfil: 'estudante')
end

Quando('dentro de {string} seleciono {string} no campo {string}') do |escopo, opcao, campo|
  within(escopo) { select opcao, from: campo }
end

Quando('dentro do formulário de edição da catraca {string} do restaurante {string} ' \
       'preencho o campo {string} com {string}') do |codigo, nome, campo, valor|
  within(formulario_da_catraca(codigo, nome)) { fill_in campo, with: valor }
end

Quando('dentro do formulário de edição da catraca {string} do restaurante {string} ' \
       'seleciono {string} no campo {string}') do |codigo, nome, opcao, campo|
  within(formulario_da_catraca(codigo, nome)) { select opcao, from: campo }
end

Quando('dentro do formulário de edição da catraca {string} do restaurante {string} ' \
       'clico no botão {string}') do |codigo, nome, botao|
  within(formulario_da_catraca(codigo, nome)) { click_button botao }
end

Quando('envio uma requisição {string} para a rota {string} da catraca {string} ' \
       'do restaurante {string}') do |metodo, rota, codigo, nome|
  catraca = Catraca.joins(:restaurant).find_by!(codigo: codigo, restaurants: { name: nome })
  @atributos_antes = catraca.attributes
  page.driver.submit(metodo.downcase.to_sym, caminho_da_catraca(rota, metodo, catraca), {})
end

Então('o responsável pela catraca {string} do restaurante {string} deve ser {string}') do |codigo, nome, responsavel|
  expect(catraca_do_feature(codigo, nome).responsavel.nome).to eq(responsavel)
end

Então('o campo {string} deve oferecer {string}') do |campo, opcao|
  expect(page).to have_select(campo, with_options: [opcao])
end

Então('o campo {string} não deve oferecer {string}') do |campo, opcao|
  expect(page).to have_no_select(campo, with_options: [opcao])
end

Então('não deve existir nenhuma catraca no restaurante {string}') do |nome|
  expect(Restaurant.find_by!(name: nome).catracas.count).to eq(0)
end

Então(/^deve existir exatamente (\d+) catracas? no restaurante "([^"]*)"$/) do |quantidade, nome|
  expect(Restaurant.find_by!(name: nome).catracas.count).to eq(quantidade.to_i)
end

Então('o elemento {string} deve existir na página') do |seletor|
  expect(page).to have_css(seletor)
end

Então('a catraca {string} do restaurante {string} deve permanecer inalterada') do |codigo, nome|
  expect(catraca_do_feature(codigo, nome).attributes).to eq(@atributos_antes)
end
# rubocop:enable Naming/AsciiIdentifiers
