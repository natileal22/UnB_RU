require 'rails_helper'

RSpec.describe GatewayCartao do
  let(:dados) { { numero: '4111 1111 1111 1111', nome: 'ANA SILVA', validade: '12/30', cvv: '123' } }

  describe '.dados_validos?' do
    it 'aceita dados completos' do
      expect(described_class.dados_validos?(**dados)).to be true
    end

    it 'recusa número com menos de 16 dígitos' do
      expect(described_class.dados_validos?(**dados, numero: '4111')).to be false
    end

    it 'recusa nome em branco' do
      expect(described_class.dados_validos?(**dados, nome: ' ')).to be false
    end

    it 'recusa validade fora do formato MM/AA' do
      expect(described_class.dados_validos?(**dados, validade: '13/30')).to be false
    end

    it 'recusa CVV com tamanho errado' do
      expect(described_class.dados_validos?(**dados, cvv: '12')).to be false
    end
  end

  describe '.autorizar' do
    it 'autoriza um cartão com limite' do
      expect(described_class.autorizar(numero: '4111111111111111')).to be true
    end

    it 'recusa um cartão sem limite' do
      expect(described_class.autorizar(numero: '4000 0000 0000 0002')).to be false
    end
  end
end