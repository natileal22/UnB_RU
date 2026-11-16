# frozen_string_literal: true

# rubocop:disable Naming/AsciiIdentifiers
def data_iso(texto)
  Date.strptime(texto, '%d/%m/%Y').iso8601
end

Dado('existem registros de acesso no período de {string} a {string}') do |inicio, fim|
  criar_registro_de_acesso('restaurante' => 'RU Darcy Ribeiro', 'catraca' => 'CAT-01',
                           'matrícula' => '241012345', 'data' => "#{data_iso(inicio)} 08:15")
  criar_registro_de_acesso('restaurante' => 'RU Darcy Ribeiro', 'catraca' => 'CAT-02',
                           'matrícula' => '241012346', 'resultado' => 'NEGADO', 'data' => "#{data_iso(fim)} 23:30")
end

Dado('não existem registros de acesso no período de {string} a {string}') do |inicio, fim|
  periodo = Time.zone.parse(data_iso(inicio)).beginning_of_day..Time.zone.parse(data_iso(fim)).end_of_day
  Access.where(occurred_at: periodo).delete_all
end

Dado('o período de {string} a {string} está aplicado no relatório') do |inicio, fim|
  fill_in 'De', with: data_iso(inicio)
  fill_in 'Até', with: data_iso(fim)
  click_button 'Aplicar filtros'
end

Dado('a catraca {string} está filtrada no relatório') do |catraca|
  fill_in 'Catraca', with: catraca
  click_button 'Aplicar filtros'
end
Dado('existe um acesso da matrícula {string} no restaurante {string} em {string}') do |matricula, restaurante, data|
  criar_registro_de_acesso('restaurante' => restaurante, 'catraca' => 'CAT-01', 'matrícula' => matricula,
                           'data' => "#{data_iso(data)} 10:00")
end

Dado('o restaurante {string} está filtrado no relatório') do |restaurante|
  select restaurante, from: 'Restaurante'
  click_button 'Aplicar filtros'
end

Dado('o resultado {string} está filtrado no relatório') do |resultado|
  select resultado, from: 'Resultado'
  click_button 'Aplicar filtros'
end
# troca o gerador por um que falha e devolve o original depois do cenario
Dado('a geração do PDF falha com erro') do
  original = GeradorPdf.method(:gerar)
  GeradorPdf.define_singleton_method(:gerar) { |**| raise 'falha simulada' }
  @restaurar_gerador = -> { GeradorPdf.define_singleton_method(:gerar, original) }
end

After { @restaurar_gerador&.call }

Quando('envio uma requisição GET para a rota de exportação com data inicial {string} ' \
       'e final {string}') do |ini, fim|
  page.driver.submit(:get, admin_exportar_relatorio_path, { data_inicial: ini, data_final: fim })
end

Então('o cabeçalho {string} deve conter {string}') do |cabecalho, texto|
  expect(page.response_headers[cabecalho].to_s).to include(texto)
end

Então('o cabeçalho {string} não deve conter {string}') do |cabecalho, texto|
  expect(page.response_headers[cabecalho].to_s).not_to include(texto)
end
# o texto do pdf vai em claro em windows 1252 entao da para procurar direto nos bytes
def corpo_do_pdf
  page.driver.response.body.b
end

Então('o PDF deve conter {string}') do |texto|
  expect(corpo_do_pdf).to include(texto.encode('Windows-1252').b)
end

Então('o PDF deve começar com {string}') do |texto|
  expect(corpo_do_pdf).to start_with(texto.b)
end

Então('o PDF não deve conter {string}') do |texto|
  expect(corpo_do_pdf).not_to include(texto.encode('Windows-1252').b)
end
# rubocop:enable Naming/AsciiIdentifiers
