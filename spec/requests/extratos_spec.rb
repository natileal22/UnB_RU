# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength -- um describe por controller com todos os casos
require 'rails_helper'

RSpec.describe 'Extratos', type: :request do
  let(:restaurante) { Restaurant.create!(name: 'RU Central') }
  let!(:ana) { User.create!(name: 'Ana', matricula: '241000001', password: 'SenhaForte123', perfil: 'estudante') }
  let!(:bruno) { User.create!(name: 'Bruno', matricula: '241000002', password: 'SenhaForte123', perfil: 'estudante') }

  def entrar_como_estudante
    post login_path, params: { matricula: ana.matricula, password: 'SenhaForte123' }
  end

  def entrar_como_operador(perfil)
    User.create!(name: perfil, matricula: '9000001', password: 'SenhaForte123', perfil: perfil)
    post operador_entrar_path, params: { matricula: '9000001', senha: 'SenhaForte123' }
  end

  def recarga(usuario, instante, valor: 10, status: 'aprovada')
    Recarga.create!(user: usuario, valor: valor, metodo: 'pix', status: status, created_at: Time.zone.parse(instante))
  end

  def acesso(usuario, instante)
    Access.create!(restaurant: restaurante, catraca: 'CAT-01', matricula: usuario.matricula, user: usuario,
                   resultado: 'LIBERADO', occurred_at: Time.zone.parse(instante))
  end

  it 'redireciona para a autenticação sem sessão' do
    get extrato_path

    expect(response).to redirect_to(operador_entrar_path)
  end

  %w[funcionario administrador].each do |perfil|
    it "nega a tela ao perfil #{perfil}" do
      entrar_como_operador(perfil)
      get extrato_path

      expect(response).to have_http_status(:forbidden)
      expect(response.body).to include('Acesso negado: esta página é exclusiva do estudante')
    end
  end

  context 'como estudante' do
    before { entrar_como_estudante }

    it 'mostra as duas listas com data, valor e status' do
      recarga(ana, '2026-09-10 12:00', valor: 25, status: 'pendente')
      acesso(ana, '2026-09-11 12:10')

      get extrato_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('id="extrato-recargas"', 'id="historico-refeicoes"', '10/09/2026 12:00',
                                       'R$ 25,00', 'Pendente', '11/09/2026 12:10', 'RU Central', 'CAT-01')
    end

    it 'mostra cabeçalho do estudante, cartões, selos e o link de limpar filtros' do
      recarga(ana, '2026-09-10 12:00', valor: 25)
      recarga(ana, '2026-09-11 12:00', valor: 5, status: 'recusada')
      acesso(ana, '2026-09-11 12:10')
      Access.update_all(valor_cobrado: 4.5)

      get extrato_path

      expect(response.body).to include('Matrícula 241000001', 'Total gasto', 'R$ 4,50', 'Total recarregado',
                                       'R$ 25,00', 'selo-ok', 'selo-erro', 'id="limpar-filtros"')
    end

    it 'não mostra os cartões com período inválido' do
      get extrato_path, params: { data_inicial: 'abc' }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).not_to include('class="cartoes"')
    end

    it 'mostra as mensagens de lista vazia' do
      get extrato_path

      expect(response.body).to include('Nenhuma recarga encontrada', 'Nenhuma refeição encontrada')
      expect(response.body).not_to include('id="extrato-recargas"', 'id="historico-refeicoes"')
    end

    it 'filtra pelo período' do
      recarga(ana, '2026-08-31 12:00')
      recarga(ana, '2026-09-15 12:00')

      get extrato_path, params: { data_inicial: '01/09/2026', data_final: '30/09/2026' }

      expect(response.body).to include('15/09/2026')
      expect(response.body).not_to include('31/08/2026')
    end

    it 'responde 422 com a mensagem quando o período é inválido' do
      get extrato_path, params: { data_inicial: 'abc' }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(PeriodoFiltro::MSG_DATA_INVALIDA)
      expect(response.body).not_to include('id="extrato-vazio"')
    end

    it 'não expõe registros de outro estudante nem aceita usuário pelos parâmetros' do
      recarga(bruno, '2026-09-12 12:00')
      acesso(bruno, '2026-09-13 12:00')

      get extrato_path, params: { user_id: bruno.id, matricula: bruno.matricula }

      expect(response.body).not_to include('12/09/2026', '13/09/2026')
      expect(response.body).to include('Nenhuma recarga encontrada', 'Nenhuma refeição encontrada')
    end
  end
end
# rubocop:enable Metrics/BlockLength
