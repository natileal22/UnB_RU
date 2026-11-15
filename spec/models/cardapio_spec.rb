require 'rails_helper'

RSpec.describe Cardapio do
  let(:hoje) { Date.new(2026, 11, 13) }

  it 'é válido com data e refeição' do
    expect(described_class.new(data: hoje, refeicao: 'almoco')).to be_valid
  end

  it 'exige a data' do
    expect(described_class.new(refeicao: 'almoco')).not_to be_valid
  end

  it 'recusa refeição desconhecida' do
    expect(described_class.new(data: hoje, refeicao: 'lanche')).not_to be_valid
  end

  it 'não aceita dois cardápios para a mesma refeição no mesmo dia' do
    described_class.create!(data: hoje, refeicao: 'almoco')
    expect(described_class.new(data: hoje, refeicao: 'almoco')).not_to be_valid
  end

  it 'aceita a mesma refeição em dias diferentes' do
    described_class.create!(data: hoje, refeicao: 'almoco')
    expect(described_class.new(data: hoje + 1, refeicao: 'almoco')).to be_valid
  end

  it 'ordena os itens como Padrão, Ovolactovegetariano e Vegetariano Estrito' do
    cardapio = described_class.create!(data: hoje, refeicao: 'almoco')
    cardapio.itens.create!(tipo: 'vegetariano_estrito', item: 'Strogonoff de Cogumelos')
    cardapio.itens.create!(tipo: 'padrao', item: 'Strogonoff de Frango')
    cardapio.itens.create!(tipo: 'ovolactovegetariano', item: 'Omelete de Queijo')

    expect(cardapio.itens_ordenados.map(&:nome_do_tipo))
      .to eq(['Padrão', 'Ovolactovegetariano', 'Vegetariano Estrito'])
  end
end