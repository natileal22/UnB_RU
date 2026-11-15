# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength -- um describe com o menu de cada perfil
require 'rails_helper'

# menu de reserva por perfil no cardapio, que usa o layout application
RSpec.describe 'Navegacao', type: :request do
  def entrar_como_estudante
    User.create!(name: 'Aluno', matricula: '241000099', password: 'SenhaForte123', perfil: 'estudante')
    post login_path, params: { matricula: '241000099', password: 'SenhaForte123' }
  end

  def entrar_como_operador(perfil)
    User.create!(name: perfil, matricula: '9000001', password: 'SenhaForte123', perfil: perfil)
    post operador_entrar_path, params: { matricula: '9000001', senha: 'SenhaForte123' }
  end

  it 'mostra Login, Cadastro e Cardápio ao visitante, sem o botão Sair' do
    get cardapio_atual_path

    expect(response.body).to include(login_path, new_user_path, operador_entrar_path)
    expect(response.body).not_to include('link-sair')
  end

  it 'mostra Cardápio, Recarga, Extrato e Sair ao estudante' do
    entrar_como_estudante
    get cardapio_atual_path

    expect(response.body).to include('>Início<', nova_recarga_path, extrato_path, sair_path, 'link-sair')
    expect(response.body).not_to include(ponto_acesso_path, admin_restaurantes_path)
  end

  it 'mostra Ponto, Operação, Histórico e Sair ao funcionário' do
    entrar_como_operador('funcionario')
    get cardapio_atual_path

    expect(response.body).to include(ponto_acesso_path, operacao_path, operador_historico_index_path, 'link-sair')
    expect(response.body).not_to include(admin_restaurantes_path)
  end

  it 'mostra Restaurantes, Relatório e Sair ao administrador' do
    entrar_como_operador('administrador')
    get cardapio_atual_path

    expect(response.body).to include(admin_restaurantes_path, admin_relatorio_path, 'link-sair')
    expect(response.body).not_to include(operacao_path)
  end

  it 'coloca a pasta de reserva no fim da busca de views' do
    expect(ApplicationController.view_paths.map(&:to_s)).to include(a_string_ending_with('app/salvaguarda/views'))
  end
end
# rubocop:enable Metrics/BlockLength
