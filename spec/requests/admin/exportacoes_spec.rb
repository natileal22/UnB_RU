# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
require 'rails_helper'

RSpec.describe 'Admin::Exportacoes', type: :request do
  let(:restaurante) { Restaurant.create!(name: 'RU Central') }
  let(:periodo) { { data_inicial: '01/09/2026', data_final: '30/09/2026' } }

  def entrar_como(perfil)
    if perfil == 'estudante'
      User.create!(name: 'Aluno', matricula: '241000099', password: 'SenhaForte123', perfil: perfil)
      post login_path, params: { matricula: '241000099', password: 'SenhaForte123' }
    else
      User.create!(name: perfil, matricula: '9000001', password: 'SenhaForte123', perfil: perfil)
      post operador_entrar_path, params: { matricula: '9000001', senha: 'SenhaForte123' }
    end
  end

  def criar_acesso
    Access.create!(restaurant: restaurante, catraca: 'CAT-01', matricula: '241000001', resultado: 'LIBERADO',
                   occurred_at: Time.zone.parse('2026-09-10 11:45'))
  end

  it 'redireciona para a autenticação sem sessão' do
    get admin_exportar_relatorio_path, params: periodo

    expect(response).to redirect_to(operador_entrar_path)
  end

  %w[funcionario estudante].each do |perfil|
    it "nega a exportação ao perfil #{perfil} sem gerar pdf" do
      criar_acesso
      entrar_como(perfil)
      get admin_exportar_relatorio_path, params: periodo

      expect(response).to have_http_status(:forbidden)
      expect(response.body).to include('Acesso negado: apenas o Administrador pode exportar o relatório')
      expect(response.media_type).not_to eq('application/pdf')
    end
  end

  context 'como administrador' do
    before { entrar_como('administrador') }

    it 'envia o pdf do período como anexo' do
      criar_acesso
      get admin_exportar_relatorio_path, params: periodo

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq('application/pdf')
      expect(response.headers['Content-Disposition']).to include('attachment')
      expect(response.headers['Content-Disposition']).to include('relatorio_operacao_2026-09-01_a_2026-09-30.pdf')
      expect(response.body.b).to start_with('%PDF-1.4')
    end

    it 'exporta só a catraca filtrada e leva o filtro no nome do arquivo' do
      criar_acesso
      Access.create!(restaurant: restaurante, catraca: 'CAT-02', matricula: '241000002', resultado: 'LIBERADO',
                     occurred_at: Time.zone.parse('2026-09-10 12:00'))
      get admin_exportar_relatorio_path, params: periodo.merge(catraca: 'CAT-01', restaurant_id: restaurante.id)

      expect(response.headers['Content-Disposition'])
        .to include('relatorio_operacao_CAT-01_2026-09-01_a_2026-09-30.pdf')
      expect(response.body.b).to include('241000001')
      expect(response.body.b).not_to include('241000002')
    end
    it 'avisa quando não há registros no período' do
      get admin_exportar_relatorio_path, params: periodo

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Não há registros no período para exportar')
      expect(response.media_type).not_to eq('application/pdf')
    end

    it 'bloqueia período inválido e sem parâmetros' do
      get admin_exportar_relatorio_path, params: { data_inicial: '31/02/2026', data_final: '28/02/2026' }
      expect(response.body).to include('Data inválida: use o formato dd/mm/aaaa')

      get admin_exportar_relatorio_path
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Data inválida: use o formato dd/mm/aaaa')
    end

    it 'mostra o erro de geração sem enviar pdf' do
      criar_acesso
      allow(GeradorPdf).to receive(:gerar).and_raise(StandardError, 'falha')
      get admin_exportar_relatorio_path, params: periodo

      expect(response).to have_http_status(:internal_server_error)
      expect(response.body).to include('Não foi possível gerar o PDF. Tente novamente')
      expect(response.media_type).not_to eq('application/pdf')
    end

    it 'leva os filtros de restaurante e catraca no link de exportação' do
      get admin_relatorio_path, params: { date_from: '2026-09-01', date_to: '2026-09-30', catraca: 'CAT-01',
                                          restaurant_id: restaurante.id }

      expect(response.body).to include('catraca=CAT-01', "restaurant_id=#{restaurante.id}")
    end

    it 'mantém o restaurante selecionado no filtro depois de aplicar os filtros' do
      restaurante
      outro = Restaurant.create!(name: 'RU Gama')
      get admin_relatorio_path, params: { restaurant_id: outro.id, catraca: 'CAT-01' }

      expect(response.body).to include("<option selected=\"selected\" value=\"#{outro.id}\">RU Gama</option>")
      expect(response.body).not_to include("selected=\"selected\" value=\"#{restaurante.id}\"")
    end

    it 'mostra o link de exportação no relatório só com o período aplicado' do
      get admin_relatorio_path
      expect(response.body).not_to include('exportar-pdf')

      get admin_relatorio_path, params: { date_from: '2026-09-01', date_to: '2026-09-30' }
      expect(response.body).to include('id="exportar-pdf"')
      expect(response.body).to include('data_inicial=01%2F09%2F2026', 'data_final=30%2F09%2F2026')
    end
  end
end
# rubocop:enable Metrics/BlockLength
