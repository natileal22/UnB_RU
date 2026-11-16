# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength -- um describe com a tarefa e os dados que ela cria
require 'rails_helper'
require 'rake'

# demo:popular so no banco de teste local e sem rede, rodando duas vezes para provar que nao duplica
RSpec.describe 'demo:popular' do
  before(:all) do
    Rails.application.load_tasks unless Rake::Task.task_defined?('demo:popular')
  end

  def popular
    Rake::Task['demo:popular'].reenable
    expect { Rake::Task['demo:popular'].invoke }.to output(/Demonstracao pronta/).to_stdout
  end

  def contagens
    [User, Restaurant, Catraca, Access, Recarga].map(&:count)
  end

  it 'cria as contas e os dados e a segunda execução não duplica nada' do
    popular
    primeira = contagens
    popular

    expect(contagens).to eq(primeira)
    expect(primeira).to eq([8, 3, 5, 12, 6])
    expect(User.where(perfil: 'estudante').count).to eq(5)
    expect(User.where(perfil: 'funcionario').count).to eq(2)
    expect(User.where(perfil: 'administrador').count).to eq(1)
  end

  it 'deixa as senhas conferirem pelo authenticate' do
    popular

    expect(User.find_by(matricula: '241012345').authenticate('Aluno@2026')).to be_truthy
    expect(User.find_by(matricula: '1234567').authenticate('Funcionario@2026')).to be_truthy
    expect(User.find_by(matricula: '7654321').authenticate('Admin@2026')).to be_truthy
  end

  it 'não troca a senha nem o saldo de uma conta que já existe' do
    User.create!(nome: 'Ana Souza', matricula: '241012345', password: 'OutraSenha1', perfil: 'estudante', saldo: 99)
    popular
    ana = User.find_by(matricula: '241012345')

    expect(ana.authenticate('OutraSenha1')).to be_truthy
    expect(ana.saldo).to eq(99)
  end

  it 'liga as catracas aos responsáveis e ao restaurante certo' do
    popular
    darcy = Restaurant.find_by!(name: 'RU Darcy Ribeiro')

    expect(darcy.catracas.find_by!(codigo: 'CAT-01').responsavel.nome).to eq('Maria Fiscal')
    expect(Restaurant.find_by!(name: 'RU Gama').catracas.first.responsavel.nome).to eq('João Operador')
    expect(darcy.catracas.find_by!(codigo: 'CAT-03')).to have_attributes(status: 'em_manutencao', responsavel: nil)
    expect(Restaurant.find_by!(name: 'RU Planaltina')).to have_attributes(status: 'inativo')
  end

  it 'cria acessos liberados e negados e recargas de cada status' do
    popular

    expect(Access.group(:resultado).count).to eq('LIBERADO' => 8, 'NEGADO' => 4)
    expect(Access.where(resultado: 'LIBERADO').distinct.pluck(:valor_cobrado)).to eq([ValidacaoEntrada::PRECO])
    expect(Access.where.not(motivo_negacao: nil).distinct.pluck(:motivo_negacao))
      .to contain_exactly('SALDO_INSUFICIENTE', 'CATRACA_INDISPONIVEL')
    expect(Access.where(user_id: nil)).to be_empty
    expect(Recarga.distinct.pluck(:status)).to contain_exactly('aprovada', 'pendente', 'recusada')
    expect(Recarga.distinct.pluck(:metodo)).to contain_exactly('pix', 'cartao_credito')
  end
end
# rubocop:enable Metrics/BlockLength
