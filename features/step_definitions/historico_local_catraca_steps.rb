# frozen_string_literal: true

# rubocop:disable Naming/AsciiIdentifiers
PAGINAS_HISTORICO = {
  'Histórico Local' => :operador_historico_index_path,
  'Autenticação' => :operador_entrar_path,
  'Gestão de Restaurantes e Catracas' => :admin_restaurantes_path,
  'Relatório Global de Operação' => :admin_relatorio_path,
  'Extrato de Recargas' => :extrato_path,
  'Histórico de Refeições' => :extrato_path
}.freeze

def caminho_da_pagina(nome)
  send(PAGINAS_HISTORICO.fetch(nome))
end

def catraca_do_feature(codigo, nome_restaurante)
  restaurante = Restaurant.find_or_create_by!(name: nome_restaurante)
  Catraca.find_or_create_by!(restaurant: restaurante, codigo: codigo)
end

Dado(/^(?:que )?existe o restaurante "([^"]*)"$/) do |nome|
  Restaurant.find_or_create_by!(name: nome)
end

Dado(/^(?:que )?estou autenticado como "([^"]*)"$/) do |perfil|
  step %(estou logado como "#{perfil}")
end

Dado('que minha sessão expirou') do
  # sem sessao de proposito o navegador comeca limpo
end

Dado('existem os acessos na catraca {string} do restaurante {string}:') do |codigo, nome, tabela|
  catraca = catraca_do_feature(codigo, nome)
  tabela.hashes.each do |linha|
    recusado = linha['resultado'].start_with?('Recusado')
    motivo = ValidacaoEntrada::MENSAGENS.key(linha['resultado'].split(': ', 2).last) if recusado
    Access.create!(restaurant: catraca.restaurant, catraca: codigo, matricula: linha['matricula'],
                   resultado: recusado ? 'NEGADO' : 'LIBERADO', motivo_negacao: motivo,
                   occurred_at: Time.zone.strptime("#{linha['data']} #{linha['hora']}", '%d/%m/%Y %H:%M'))
  end
end

Dado('a catraca {string} do restaurante {string} está vinculada ao funcionário') do |codigo, nome|
  catraca_do_feature(codigo, nome).update!(responsavel: @usuario_logado)
end

Dado('nenhuma catraca está vinculada ao funcionário') do
  Catraca.where(responsavel_id: @usuario_logado.id).update_all(responsavel_id: nil)
end

Dado(/^(?:que )?existe a catraca "([^"]*)" no restaurante "([^"]*)" com:$/) do |codigo, nome, tabela|
  dados = tabela.rows_hash
  responsavel = User.find_by!(nome: dados['responsavel']) if dados['responsavel']
  catraca_do_feature(codigo, nome).update!(status: codigo_de_status(dados.fetch('status')), responsavel: responsavel)
end

Dado('estou na página {string}') do |nome|
  visit caminho_da_pagina(nome)
end

Quando('acesso a página {string}') do |nome|
  visit caminho_da_pagina(nome)
end

Quando('dentro de {string} preencho o campo {string} com {string}') do |escopo, campo, valor|
  within(escopo) { fill_in campo, with: valor }
end

Quando('dentro de {string} clico no botão {string}') do |escopo, botao|
  within(escopo) { click_button botao }
end

Então('devo ser redirecionado para a página {string}') do |nome|
  expect(page).to have_current_path(caminho_da_pagina(nome))
end

Então('a lista {string} deve exibir {string}') do |seletor, texto|
  expect(page).to have_css(seletor, text: texto)
end

Então('o elemento {string} deve ter o texto {string}') do |seletor, texto|
  expect(page).to have_css(seletor, text: texto)
end

Então('o elemento {string} não deve ter o texto {string}') do |seletor, texto|
  expect(page).to have_css(seletor)
  expect(find(seletor)).to have_no_content(texto)
end

Então('o elemento {string} não deve existir na página') do |seletor|
  expect(page).to have_no_css(seletor)
end

Então('a resposta deve ter status {int}') do |status|
  expect(page.status_code).to eq(status)
end
# rubocop:enable Naming/AsciiIdentifiers
