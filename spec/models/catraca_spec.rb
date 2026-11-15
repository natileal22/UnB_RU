# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
require 'rails_helper'

RSpec.describe Catraca, type: :model do
  let(:restaurante) { Restaurant.create!(name: 'RU Central') }

  it 'exige código único dentro do mesmo restaurante' do
    described_class.create!(restaurant: restaurante, codigo: 'CAT-01')
    repetida = described_class.new(restaurant: restaurante, codigo: 'CAT-01')

    expect(repetida).not_to be_valid
  end

  it 'pode ter um responsável e é encontrada por vinculadas_a' do
    funcionario = User.create!(name: 'Func', matricula: '9000001', password: 'SenhaForte123', perfil: 'funcionario')
    vinculada = described_class.create!(restaurant: restaurante, codigo: 'CAT-01', responsavel: funcionario)
    described_class.create!(restaurant: restaurante, codigo: 'CAT-02')

    expect(described_class.vinculadas_a(funcionario)).to eq([vinculada])
  end

  it 'é válida sem responsável' do
    expect(described_class.new(restaurant: restaurante, codigo: 'CAT-09')).to be_valid
  end

  it 'só fica disponível quando está ativa' do
    expect(described_class.new(status: 'ativa')).to be_disponivel
    expect(described_class.new(status: 'em_manutencao')).not_to be_disponivel
  end

  describe 'regras de gestão' do
    def mensagem_de(**atributos)
      catraca = described_class.new({ restaurant: restaurante, codigo: 'CAT-05' }.merge(atributos))
      catraca.valid?(:gestao)
      catraca.errors.first&.message
    end

    it 'rejeita código com formato inválido' do
      ['CAT 01', 'CAT#01', 'CAT/01'].each do |codigo|
        expect(mensagem_de(codigo: codigo)).to eq('Código da catraca contém caracteres inválidos')
      end
    end

    it 'rejeita código vazio e acima de 20 caracteres' do
      expect(mensagem_de(codigo: '')).to eq('Código da catraca é obrigatório')
      expect(mensagem_de(codigo: 'A' * 21)).to eq('Código da catraca deve ter no máximo 20 caracteres')
      expect(mensagem_de(codigo: 'A' * 20)).to be_nil
    end

    it 'não diferencia maiúsculas no código repetido do mesmo restaurante' do
      described_class.create!(restaurant: restaurante, codigo: 'CAT-01')

      expect(mensagem_de(codigo: 'cat-01')).to eq('Já existe uma catraca com este código neste restaurante')
    end

    it 'aceita o mesmo código em outro restaurante' do
      described_class.create!(restaurant: restaurante, codigo: 'CAT-01')
      outro = Restaurant.create!(name: 'RU Gama')

      expect(described_class.new(restaurant: outro, codigo: 'CAT-01')).to be_valid(:gestao)
    end

    it 'não ativa catraca em restaurante inativo' do
      restaurante.update!(status: 'inativo')

      expect(mensagem_de(status: 'ativa')).to eq('Não é possível ativar a catraca porque o restaurante está Inativo')
      expect(mensagem_de(status: 'inativa')).to be_nil
    end

    it 'aceita catraca sem horário e com horário válido' do
      expect(mensagem_de).to be_nil
      expect(mensagem_de(horario_abertura: '11:00', horario_fechamento: '14:00')).to be_nil
    end

    it 'rejeita abertura igual ou posterior ao fechamento' do
      aviso = 'O horário de abertura da catraca deve ser anterior ao horário de fechamento'

      expect(mensagem_de(horario_abertura: '14:00', horario_fechamento: '11:00')).to eq(aviso)
      expect(mensagem_de(horario_abertura: '11:00', horario_fechamento: '11:00')).to eq(aviso)
    end

    it 'rejeita horário que não é hora' do
      expect(mensagem_de(horario_abertura: '25:99', horario_fechamento: '14:00'))
        .to eq('Horário de abertura da catraca é inválido')
      expect(mensagem_de(horario_abertura: '11:00', horario_fechamento: 'abc'))
        .to eq('Horário de fechamento da catraca é inválido')
    end

    it 'rejeita só um dos dois horários preenchido' do
      aviso = 'Informe os horários de abertura e fechamento da catraca juntos'

      expect(mensagem_de(horario_abertura: '11:00')).to eq(aviso)
      expect(mensagem_de(horario_fechamento: '14:00')).to eq(aviso)
    end

    it 'não aceita estudante como responsável' do
      aluno = User.create!(name: 'Ana', matricula: '241000001', password: 'SenhaForte123', perfil: 'estudante')

      expect(mensagem_de(responsavel: aluno)).to eq('Responsável deve ser funcionário ou administrador')
    end

    it 'não deixa mudar o código nem o restaurante de catraca com acessos' do
      catraca = described_class.create!(restaurant: restaurante, codigo: 'CAT-01', status: 'inativa')
      Access.create!(restaurant: restaurante, catraca: 'CAT-01', matricula: '241000001', resultado: 'LIBERADO',
                     occurred_at: Time.current)
      aviso = 'Não é possível alterar o código ou o restaurante de uma catraca com registros de acesso'

      catraca.codigo = 'CAT-10'
      expect(catraca.valid?(:gestao)).to be(false)
      expect(catraca.errors.first.message).to eq(aviso)

      catraca.restore_attributes
      catraca.restaurant = Restaurant.create!(name: 'RU Gama')
      expect(catraca.valid?(:gestao)).to be(false)
      expect(catraca.errors.first.message).to eq(aviso)
    end

    it 'deixa mudar o status de catraca com acessos e o código de catraca sem acessos' do
      catraca = described_class.create!(restaurant: restaurante, codigo: 'CAT-01', status: 'inativa')
      catraca.codigo = 'CAT-10'
      expect(catraca).to be_valid(:gestao)

      catraca.save!
      Access.create!(restaurant: restaurante, catraca: 'CAT-10', matricula: '241000001', resultado: 'LIBERADO',
                     occurred_at: Time.current)
      catraca.status = 'em_manutencao'
      expect(catraca).to be_valid(:gestao)
    end

    it 'só libera a remoção de catraca inativa sem responsável e sem acessos' do
      catraca = described_class.create!(restaurant: restaurante, codigo: 'CAT-01', status: 'inativa')
      expect(catraca.motivo_bloqueio_remocao).to be_nil

      Access.create!(restaurant: restaurante, catraca: 'CAT-01', matricula: '241000001', resultado: 'LIBERADO',
                     occurred_at: Time.current)
      expect(catraca.motivo_bloqueio_remocao).to include('responsável ou registros de acesso')
      expect(described_class.new(status: 'ativa').motivo_bloqueio_remocao).to include('catraca Ativa')
    end
  end
end
# rubocop:enable Metrics/BlockLength
