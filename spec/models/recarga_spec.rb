require 'rails_helper'

RSpec.describe Recarga do
  let(:estudante) { User.create!(name: 'Ana Silva', matricula: '231000001', password: 'senha123', saldo: 10) }

  def nova_recarga(valor: 30, metodo: 'pix')
    described_class.new(user: estudante, valor: valor, metodo: metodo)
  end

  describe 'validações' do
    it 'aceita valor positivo com PIX' do
      expect(nova_recarga).to be_valid
    end

    it 'aceita valor positivo com cartão de crédito' do
      expect(nova_recarga(metodo: 'cartao_credito')).to be_valid
    end

    it "recusa valor negativo com a mensagem 'Valor de recarga inválido'" do
      recarga = nova_recarga(valor: -10)
      expect(recarga).not_to be_valid
      expect(recarga.errors.full_messages.first).to eq('Valor de recarga inválido')
    end

    it 'recusa valor zero' do
      expect(nova_recarga(valor: 0)).not_to be_valid
    end

    it 'recusa valor em branco' do
      expect(nova_recarga(valor: nil)).not_to be_valid
    end

    it 'recusa método de pagamento desconhecido' do
      expect(nova_recarga(metodo: 'boleto')).not_to be_valid
    end

    it 'nasce com status pendente' do
      expect(nova_recarga).to be_pendente
    end
  end

  describe '#aprovar!' do
    it 'marca a recarga como aprovada e soma o valor ao saldo' do
      recarga = nova_recarga(valor: 30)
      recarga.save!
      recarga.aprovar!

      expect(recarga).to be_aprovada
      expect(estudante.reload.saldo).to eq(40)
    end

    it 'não credita duas vezes a mesma recarga' do
      recarga = nova_recarga(valor: 30)
      recarga.save!
      recarga.aprovar!

      expect { recarga.aprovar! }.to raise_error(RuntimeError, 'Recarga já processada')
      expect(estudante.reload.saldo).to eq(40)
    end
  end

  describe '#recusar!' do
    it 'marca a recarga como recusada sem mexer no saldo' do
      recarga = nova_recarga(metodo: 'cartao_credito')
      recarga.save!
      recarga.recusar!

      expect(recarga).to be_recusada
      expect(estudante.reload.saldo).to eq(10)
    end
  end
end