require 'rails_helper'

RSpec.describe ItemCardapio do
  let(:cardapio) { Cardapio.create!(data: Date.new(2026, 11, 13), refeicao: 'jantar') }

  it 'é válido com tipo e item' do
    expect(described_class.new(cardapio: cardapio, tipo: 'padrao', item: 'Frango assado')).to be_valid
  end

  it 'exige o nome do item' do
    expect(described_class.new(cardapio: cardapio, tipo: 'padrao', item: '')).not_to be_valid
  end

  it 'recusa tipo fora das três opções' do
    expect(described_class.new(cardapio: cardapio, tipo: 'vegano', item: 'Salada')).not_to be_valid
  end

  it 'mostra o nome do tipo por extenso' do
    expect(described_class.new(tipo: 'vegetariano_estrito').nome_do_tipo).to eq('Vegetariano Estrito')
  end
end