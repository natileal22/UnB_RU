require 'rails_helper'

RSpec.describe HorarioRefeicao do
  def as(hora)
    Time.zone.parse("2026-11-13 #{hora}")
  end

  describe '.atual' do
    it 'identifica o café da manhã' do
      expect(described_class.atual(as('08:00')).nome).to eq('Café da manhã')
    end

    it 'identifica o almoço' do
      expect(described_class.atual(as('12:00')).nome).to eq('Almoço')
    end

    it 'identifica o jantar' do
      expect(described_class.atual(as('18:00')).nome).to eq('Jantar')
    end

    it 'considera o horário de início como dentro da refeição' do
      expect(described_class.atual(as('11:00')).nome).to eq('Almoço')
    end

    it 'considera o horário de término como fora da refeição' do
      expect(described_class.atual(as('14:30'))).to be_nil
    end

    it 'devolve nil entre as refeições' do
      expect(described_class.atual(as('15:30'))).to be_nil
    end
  end

  describe '.proxima' do
    it 'aponta o jantar no meio da tarde' do
      expect(described_class.proxima(as('15:30'))).to have_attributes(nome: 'Jantar', inicio: '17:00')
    end

    it 'aponta o almoço no meio da manhã' do
      expect(described_class.proxima(as('10:00')).nome).to eq('Almoço')
    end

    it 'volta para o café da manhã depois do jantar' do
      expect(described_class.proxima(as('22:00')).nome).to eq('Café da manhã')
    end
  end

  describe '.por_nome' do
    it 'encontra a refeição sem diferenciar maiúsculas' do
      expect(described_class.por_nome('jantar').chave).to eq('jantar')
    end
  end
end