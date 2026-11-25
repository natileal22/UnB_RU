require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) do
    described_class.new(name: 'Ana Silva', matricula: '123456789', password: 'SenhaForte123')
  end

  it 'é válido' do
    is_expected.to be_valid
  end

  it 'rejeita matrícula com formato incorreto' do
    user.matricula = '123'

    expect(user).not_to be_valid
    expect(user.errors[:matricula]).to include('inválida')
  end

  it 'rejeita matrícula composta por dígitos repetidos' do
    user.matricula = '999999999'

    expect(user).not_to be_valid
    expect(user.errors[:matricula]).to include('inválida')
  end

  it 'exige matrícula única' do
    described_class.create!(name: 'Ana Silva', matricula: '123456789', password: 'SenhaForte123')
    duplicate = described_class.new(name: 'Bruno Oliveira', matricula: '123456789', password: 'AcessoRU456')

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:matricula]).to include('já cadastrada')
  end

  it 'aceita matrícula SIAPE de 7 dígitos para funcionário' do
    user = described_class.new(
      nome: 'Carlos Operador',
      matricula: '1234567',
      password: 'SenhaCorreta123',
      perfil: 'funcionario'
    )
    expect(user).to be_valid
    expect(user.operador_autorizado?).to be(true)
  end

  it 'rejeita matrícula de 9 dígitos para funcionário' do
    user = described_class.new(
      nome: 'Carlos Operador',
      matricula: '123456789',
      password: 'SenhaCorreta123',
      perfil: 'funcionario'
    )
    expect(user).not_to be_valid
  end
end
