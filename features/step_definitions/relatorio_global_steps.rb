# frozen_string_literal: true

Dado('estou na página de Relatório Global de Acessos') do
  visit admin_relatorio_path
end

Dado('que existem os seguintes registros de acesso:') do |registros|
  registros.hashes.each { |registro| criar_registro_de_acesso(registro) }
end

Dado('que existem registros de acesso nos restaurantes {string} e {string}') do |primeiro, segundo|
  criar_registro_de_acesso('restaurante' => primeiro, 'catraca' => 'CAT-01',
                           'matrícula' => '241012345', 'resultado' => 'LIBERADO')
  criar_registro_de_acesso('restaurante' => segundo, 'catraca' => 'CAT-01',
                           'matrícula' => '241012346', 'resultado' => 'LIBERADO')
end

Dado('que existem acessos registrados entre {string} e {string}') do |inicio, fim|
  criar_registro_de_acesso('restaurante' => 'RU Darcy Ribeiro', 'catraca' => 'CAT-01',
                           'matrícula' => '241012345', 'resultado' => 'LIBERADO',
                           'data' => inicio)
  criar_registro_de_acesso('restaurante' => 'RU Darcy Ribeiro', 'catraca' => 'CAT-02',
                           'matrícula' => '241012346', 'resultado' => 'NEGADO',
                           'data' => fim)
end

Dado('que existem acessos com resultado {string}') do |resultado|
  criar_registro_de_acesso('restaurante' => 'RU Gama', 'catraca' => 'CAT-01',
                           'matrícula' => '241012347', 'resultado' => resultado,
                           'data' => '2026-10-20')
end

Dado('que existem acessos com resultado {string} e {string}') do |primeiro, segundo|
  criar_registro_de_acesso('restaurante' => 'RU Gama', 'catraca' => 'CAT-01',
                           'matrícula' => '241012347', 'resultado' => primeiro,
                           'data' => '2026-10-20')
  criar_registro_de_acesso('restaurante' => 'RU Gama', 'catraca' => 'CAT-02',
                           'matrícula' => '241012348', 'resultado' => segundo,
                           'data' => '2026-10-21')
end

Dado('existem acessos com resultado {string} e {string}') do |primeiro, segundo|
  criar_registro_de_acesso('restaurante' => 'RU Gama', 'catraca' => 'CAT-01',
                           'matrícula' => '241012347', 'resultado' => primeiro,
                           'data' => '2026-10-20')
  criar_registro_de_acesso('restaurante' => 'RU Gama', 'catraca' => 'CAT-02',
                           'matrícula' => '241012348', 'resultado' => segundo,
                           'data' => '2026-10-21')
end

Dado('que não existem acessos para a catraca {string}') do |catraca|
  Access.where(catraca: catraca).delete_all
end

Quando('consulto o relatório sem aplicar filtros') do
  visit admin_relatorio_path
end

Quando('filtro o relatório pelo restaurante {string}') do |restaurante|
  @restaurante_filtrado = restaurante
  visit admin_relatorio_path
  select restaurante, from: 'Restaurante'
  click_button 'Aplicar filtros'
end

Quando('filtro o relatório pela catraca {string} do restaurante {string}') do |catraca, restaurante|
  @restaurante_filtrado = restaurante
  visit admin_relatorio_path
  select restaurante, from: 'Restaurante'
  fill_in 'Catraca', with: catraca
  click_button 'Aplicar filtros'
end

Quando('seleciono o agrupamento por restaurante e catraca') do
  check 'Agrupar por restaurante e catraca'
  click_button 'Aplicar filtros'
end

Quando('filtro o período de {string} até {string}') do |inicio, fim|
  fill_in 'De', with: inicio
  fill_in 'Até', with: fim
end

Quando('filtro o resultado por {string}') do |resultado|
  select resultado.capitalize, from: 'Resultado'
  click_button 'Aplicar filtros'
end

Quando('filtro o relatório pela catraca {string}') do |catraca|
  fill_in 'Catraca', with: catraca
  click_button 'Aplicar filtros'
end

Quando('tento acessar diretamente a página de Relatório Global de Acessos') do
  visit admin_relatorio_path
end

Então('o sistema deve exibir todos os {int} registros de acesso') do |quantidade|
  expect(page).to have_css('tbody tr', count: quantidade)
end

Então('deve exibir o restaurante, a catraca, a matrícula, o resultado e a data de cada registro') do
  expect(page).to have_css('th', text: 'Restaurante')
  expect(page).to have_css('th', text: 'Catraca')
  expect(page).to have_css('th', text: 'Matrícula')
  expect(page).to have_css('th', text: 'Resultado')
  expect(page).to have_css('th', text: 'Data')
end

Então('o sistema deve exibir apenas os acessos do restaurante {string}') do |restaurante|
  expect(page).to have_css('tbody tr', text: restaurante)
end

Então('não deve exibir acessos de outros restaurantes') do
  outros = Restaurant.where.not(name: @restaurante_filtrado).pluck(:name)
  outros.each { |restaurante| expect(page).to have_no_css('tbody tr', text: restaurante) }
end

Então('o sistema deve exibir apenas os acessos da catraca {string}') do |catraca|
  expect(page).to have_css('tbody tr', text: catraca)
end

Então('não deve exibir acessos da catraca {string}') do |catraca|
  expect(page).to have_no_css('tbody tr', text: catraca)
end

Então('o sistema deve agrupar os registros por restaurante') do
  expect(page).to have_css('th', text: 'Restaurante')
end

Então('dentro de cada restaurante deve agrupar os registros por catraca') do
  expect(page).to have_css('th', text: 'Catraca')
end

Então('deve exibir a quantidade de acessos de cada grupo') do
  expect(page).to have_css('th', text: 'Quantidade de acessos')
end

Então('o sistema deve exibir apenas os acessos negados nesse período') do
  expect(page).to have_css('tbody tr', text: 'NEGADO')
end

Então('não deve exibir acessos fora do período informado') do
  expect(page).to have_no_content('241012345')
end

Então('não deve exibir acessos LIBERADOs') do
  expect(page).to have_no_content('LIBERADO')
end

Então('não deve exibir registros de outras catracas') do
  expect(page).to have_no_content('CAT-01')
end

Então('não deve exibir os registros de acesso') do
  expect(page).to have_no_content('241012345')
  expect(page).to have_no_content('241012346')
  expect(page).to have_no_content('241012347')
end

private

def criar_registro_de_acesso(registro)
  restaurante = Restaurant.find_or_create_by!(name: registro.fetch('restaurante'))
  Access.create!(
    restaurant: restaurante,
    catraca: registro.fetch('catraca', 'CAT-01'),
    matricula: registro.fetch('matrícula', '241012345'),
    resultado: registro.fetch('resultado', 'LIBERADO'),
    occurred_at: Time.zone.parse(registro.fetch('data', '2026-10-20'))
  )
end
