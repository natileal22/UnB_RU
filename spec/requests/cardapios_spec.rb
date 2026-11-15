require 'rails_helper'

RSpec.describe 'Cardápio da refeição atual', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  after { travel_back }

  def as(hora)
    travel_to Time.zone.parse("2026-11-13 #{hora}")
  end

  it 'mostra as três opções do almoço cadastrado' do
    as('12:00')
    cardapio = Cardapio.create!(data: Time.zone.today, refeicao: 'almoco')
    cardapio.itens.create!(tipo: 'padrao', item: 'Strogonoff de Frango')
    cardapio.itens.create!(tipo: 'ovolactovegetariano', item: 'Omelete de Queijo')
    cardapio.itens.create!(tipo: 'vegetariano_estrito', item: 'Strogonoff de Cogumelos')

    get cardapio_atual_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Refeição atual: <strong>Almoço</strong>', 'Strogonoff de Frango',
                                     'Omelete de Queijo', 'Strogonoff de Cogumelos')
  end

  it 'não mostra o cardápio de outro dia' do
    as('12:00')
    Cardapio.create!(data: Time.zone.yesterday, refeicao: 'almoco')
            .itens.create!(tipo: 'padrao', item: 'Prato de ontem')

    get cardapio_atual_path

    expect(response.body).not_to include('Prato de ontem')
    expect(response.body).to include('O cardápio para o Almoço de hoje ainda não foi disponibilizado')
  end

  it 'avisa quando o cardápio do jantar ainda não foi cadastrado' do
    as('18:00')
    get cardapio_atual_path
    expect(response.body).to include('O cardápio para o Jantar de hoje ainda não foi disponibilizado')
  end

  it 'informa a próxima refeição fora do horário de funcionamento' do
    as('15:30')
    get cardapio_atual_path
    expect(response.body).to include('Nenhuma refeição está sendo servida neste horário', 'Jantar às 17:00')
  end

  it 'abre sem login' do
    as('12:00')
    get cardapio_atual_path
    expect(response).to have_http_status(:ok)
  end
end