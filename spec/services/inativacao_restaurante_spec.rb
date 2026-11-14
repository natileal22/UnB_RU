# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InativacaoRestaurante do
  let(:restaurante) { Restaurant.create!(name: 'RU Central') }

  it 'inativa o restaurante e as catracas ativas e mantém as em manutenção' do
    ativa = Catraca.create!(restaurant: restaurante, codigo: 'CAT-01', status: 'ativa')
    manutencao = Catraca.create!(restaurant: restaurante, codigo: 'CAT-02', status: 'em_manutencao')

    resultado = described_class.new(restaurante: restaurante).call

    expect(resultado.mensagem).to eq('Restaurante e suas catracas ativas foram inativados')
    expect(restaurante.reload.status).to eq('inativo')
    expect([ativa.reload.status, manutencao.reload.status]).to eq(%w[inativa em_manutencao])
  end

  it 'não mexe nas catracas de outro restaurante' do
    outra = Catraca.create!(restaurant: Restaurant.create!(name: 'RU Gama'), codigo: 'CAT-01')

    described_class.new(restaurante: restaurante).call

    expect(outra.reload.status).to eq('ativa')
  end
end
