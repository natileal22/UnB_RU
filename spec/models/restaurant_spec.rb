# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
require 'rails_helper'

RSpec.describe Restaurant, type: :model do
  it 'requires a unique name' do
    described_class.create!(name: 'RU Darcy Ribeiro')
    duplicate = described_class.new(name: 'RU Darcy Ribeiro')

    expect(duplicate).not_to be_valid
    expect(duplicate.errors.details[:name]).to include(a_hash_including(error: :taken))
  end

  context 'com os dados de gestão' do
    let(:dados) do
      { name: 'RU Gama', localizacao: 'Campus Gama', capacidade: 300, horario_abertura: '11:00',
        horario_fechamento: '14:00' }
    end

    def mensagem_de(atributos)
      restaurante = described_class.new(dados.merge(atributos))
      restaurante.valid?(:gestao)
      restaurante.errors.first&.message
    end

    it 'aceita dados completos e os limites 1 e 5000' do
      expect(described_class.new(dados)).to be_valid(:gestao)
      [1, 5000].each { |valor| expect(mensagem_de(capacidade: valor)).to be_nil }
    end

    it 'não diferencia maiúsculas no nome repetido' do
      described_class.create!(name: 'RU Gama')

      expect(mensagem_de(name: 'ru gama')).to eq('Já existe um restaurante com este nome')
    end

    [0, 5001, -1, '10,5', 'abc', ''].each do |capacidade|
      it "rejeita a capacidade #{capacidade.inspect}" do
        expect(mensagem_de(capacidade: capacidade))
          .to eq('Capacidade inválida: informe um número inteiro entre 1 e 5000')
      end
    end

    it 'exige localização' do
      expect(mensagem_de(localizacao: '')).to eq('Localização do restaurante é obrigatória')
    end

    it 'exige abertura antes do fechamento' do
      expect(mensagem_de(horario_abertura: '14:00', horario_fechamento: '14:00'))
        .to eq('O horário de abertura deve ser anterior ao horário de fechamento')
    end

    it 'distingue horário vazio de horário inválido' do
      expect(mensagem_de(horario_abertura: '')).to eq('Horário de abertura é obrigatório')
      expect(mensagem_de(horario_abertura: '25:99')).to eq('Horário de abertura é inválido')
      expect(mensagem_de(horario_fechamento: '')).to eq('Horário de fechamento é obrigatório')
    end
  end

  it 'bloqueia a remoção quando há catraca' do
    restaurante = described_class.create!(name: 'RU Gama')
    Catraca.create!(restaurant: restaurante, codigo: 'CAT-01')

    expect(restaurante.motivo_bloqueio_remocao).to include('catracas vinculadas')
    expect(described_class.create!(name: 'RU Asa Norte').motivo_bloqueio_remocao).to be_nil
  end
end
# rubocop:enable Metrics/BlockLength
