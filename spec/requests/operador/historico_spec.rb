# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
require 'rails_helper'

RSpec.describe 'Operador::Historico', type: :request do
  let(:restaurante) { Restaurant.create!(name: 'RU Central') }

  def entrar_como(perfil)
    if perfil == 'estudante'
      User.create!(name: 'Aluno', matricula: '241000099', password: 'SenhaForte123', perfil: perfil)
      post login_path, params: { matricula: '241000099', password: 'SenhaForte123' }
    else
      User.create!(name: perfil, matricula: '9000001', password: 'SenhaForte123', perfil: perfil)
      post operador_entrar_path, params: { matricula: '9000001', senha: 'SenhaForte123' }
    end
  end

  it 'redireciona para a autenticação do operador sem sessão' do
    get operador_historico_index_path

    expect(response).to redirect_to(operador_entrar_path)
  end

  %w[estudante administrador].each do |perfil|
    it "nega o histórico ao perfil #{perfil}" do
      entrar_como(perfil)
      get operador_historico_index_path

      expect(response).to have_http_status(:forbidden)
      expect(response.body).to include('Acesso negado: esta página é exclusiva do funcionário')
    end
  end

  context 'como funcionário' do
    before { entrar_como('funcionario') }

    it 'avisa quando não há catraca vinculada' do
      get operador_historico_index_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Nenhuma catraca vinculada a você. Procure o administrador')
    end

    it 'lista os acessos das catracas vinculadas e esconde os das outras' do
      Catraca.create!(restaurant: restaurante, codigo: 'CAT-01', responsavel: User.last)
      Catraca.create!(restaurant: restaurante, codigo: 'CAT-02')
      Access.create!(restaurant: restaurante, catraca: 'CAT-01', matricula: '241000001', resultado: 'LIBERADO',
                     occurred_at: Time.zone.parse('2026-09-10 11:45'))
      Access.create!(restaurant: restaurante, catraca: 'CAT-02', matricula: '241000002', resultado: 'LIBERADO',
                     occurred_at: Time.zone.parse('2026-09-10 11:50'))
      get operador_historico_index_path

      expect(response.body).to include('241000001')
      expect(response.body).not_to include('241000002')
    end

    it 'mostra mensagem quando a catraca não tem acessos' do
      Catraca.create!(restaurant: restaurante, codigo: 'CAT-01', responsavel: User.last)
      get operador_historico_index_path

      expect(response.body).to include('Nenhum acesso registrado nesta catraca')
    end

    it 'responde 422 com alerta quando o período é inválido' do
      Catraca.create!(restaurant: restaurante, codigo: 'CAT-01', responsavel: User.last)
      get operador_historico_index_path, params: { data_inicial: '30/09/2026', data_final: '01/09/2026' }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('A data inicial não pode ser posterior à data final')
    end
  end
end
# rubocop:enable Metrics/BlockLength
