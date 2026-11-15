World(ActiveSupport::Testing::TimeHelpers)

After { travel_back }

Dado('que o horário do sistema é {string}') do |hora|
  travel_to Time.zone.parse("#{Time.zone.today} #{hora}")
end

Dado('a refeição {string} está em andamento') do |nome|
  expect(HorarioRefeicao.atual&.nome).to eq(nome)
end

Dado('nenhuma refeição está sendo servida no momento') do
  expect(HorarioRefeicao.atual).to be_nil
end

Dado('existe um cardápio cadastrado para a data de hoje e refeição {string} com as opções:') do |nome, tabela|
  cardapio = Cardapio.create!(data: Time.zone.today, refeicao: HorarioRefeicao.por_nome(nome).chave)
  tabela.hashes.each do |linha|
    tipo = ItemCardapio::TIPOS.key(linha['Tipo'])
    cardapio.itens.create!(tipo: tipo, item: linha['Item'])
  end
end

Dado(/^não existe um cardápio cadastrado para o (.+) na data de hoje$/) do |nome|
  refeicao = HorarioRefeicao.por_nome(nome)
  expect(Cardapio.exists?(data: Time.zone.today, refeicao: refeicao.chave)).to be false
end

Quando('o estudante acessa a página do cardápio atual') do
  visit cardapio_atual_path
end

Então('o sistema deve exibir a refeição atual como {string}') do |nome|
  expect(page).to have_content("Refeição atual: #{nome}")
end

Então(/^deve apresentar as três opções: (.+)$/) do |lista|
  opcoes = lista.split(',').map(&:strip)
  expect(opcoes.size).to eq(3)
  opcoes.each { |opcao| expect(page).to have_css('.cardapio-tipo', text: opcao) }
end

Então(/^deve informar o horário do próximo serviço disponível \("(.+)"\)$/) do |texto|
  expect(page).to have_content(texto)
end