# frozen_string_literal: true

# rubocop:disable Naming/AsciiIdentifiers
COLUNAS_RESTAURANTE = {
  'localizacao' => :localizacao, 'capacidade' => :capacidade,
  'abertura' => :horario_abertura, 'fechamento' => :horario_fechamento
}.freeze

def caminho_do_restaurante(rota, metodo, restaurante)
  case rota
  when 'novo' then new_admin_restaurante_path
  when 'criar' then admin_restaurantes_path
  when 'editar' then metodo == 'GET' ? edit_admin_restaurante_path(restaurante) : admin_restaurante_path(restaurante)
  when 'remover' then admin_restaurante_path(restaurante)
  else public_send("#{rota}_admin_restaurante_path", restaurante)
  end
end

Dado('existe o restaurante {string} com:') do |nome, tabela|
  atributos = tabela.rows_hash.to_h do |chave, valor|
    chave == 'status' ? [:status, codigo_de_status(valor)] : [COLUNAS_RESTAURANTE.fetch(chave), valor]
  end
  Restaurant.find_or_create_by!(name: nome).update!(atributos)
end

Dado('existem os restaurantes:') do |tabela|
  tabela.hashes.each { |linha| Restaurant.create!(name: linha['nome']) }
end

Dado('existem as catracas no restaurante {string}:') do |nome, tabela|
  restaurante = Restaurant.find_by!(name: nome)
  tabela.hashes.each do |linha|
    Catraca.create!(restaurant: restaurante, codigo: linha['codigo'], status: codigo_de_status(linha['status']))
  end
end

Dado(/^a validação nativa do navegador está desativada no formulário .+$/) do
  # rack_test nao valida no navegador entao nao ha o que desativar
end

Quando('clico em {string}') do |seletor|
  find(seletor).click
end

Quando('clico em {string} e aceito a confirmação {string}') do |seletor, texto|
  expect(find(seletor).find(:xpath, 'ancestor::form')['data-turbo-confirm']).to eq(texto)
  find(seletor).click
end

Quando('dentro do formulário de edição do restaurante {string} preencho o campo {string} ' \
       'com {string}') do |nome, campo, valor|
  within("#editar-form-restaurante-#{nome.parameterize}") { fill_in campo, with: valor }
end

Quando('dentro do formulário de edição do restaurante {string} clico no botão {string}') do |nome, botao|
  within("#editar-form-restaurante-#{nome.parameterize}") { click_button botao }
end

Quando('envio uma requisição {string} para a rota {string} do restaurante {string}') do |metodo, rota, nome|
  restaurante = Restaurant.find_by!(name: nome)
  @atributos_antes = restaurante.attributes
  page.driver.submit(metodo.downcase.to_sym, caminho_do_restaurante(rota, metodo, restaurante), {})
end

Então('nenhum restaurante deve estar cadastrado') do
  expect(Restaurant.count).to eq(0)
end

Então('dentro de {string} o campo {string} deve continuar preenchido com {string}') do |escopo, campo, valor|
  within(escopo) { expect(find_field(campo).value).to eq(valor) }
end

Então(/^deve existir exatamente (\d+) restaurantes? no banco$/) do |quantidade|
  expect(Restaurant.count).to eq(quantidade.to_i)
end

Então('o elemento {string} deve ter o texto exato {string}') do |seletor, texto|
  expect(page).to have_css(seletor, exact_text: texto)
end

Então('a lista {string} deve exibir {string} antes de {string}') do |seletor, primeiro, segundo|
  expect(find(seletor).text).to match(/#{Regexp.escape(primeiro)}.*#{Regexp.escape(segundo)}/m)
end

Então('o restaurante {string} não deve existir') do |nome|
  expect(Restaurant.exists?(name: nome)).to be(false)
end

Então('o restaurante {string} deve continuar existindo') do |nome|
  expect(Restaurant.exists?(name: nome)).to be(true)
end

Então('o restaurante {string} deve permanecer inalterado') do |nome|
  expect(Restaurant.find_by!(name: nome).attributes).to eq(@atributos_antes)
end
# rubocop:enable Naming/AsciiIdentifiers
