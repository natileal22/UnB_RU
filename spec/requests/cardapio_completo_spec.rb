# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength -- um describe com o dia, a semana e a reserva do cardapio completo
require 'rails_helper'

# cardapio completo sem rede, a api e sempre trocada por um stub do cliente
RSpec.describe 'Cardapio completo', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:segunda) { Date.new(2026, 11, 16) }

  before { travel_to Time.zone.local(2026, 11, 16, 12, 0) }

  after { travel_back }

  def dia_da_api(data, prato)
    { 'data' => data.iso8601,
      'refeicoes' => {
        'cafe_da_manha' => { 'complemento_padrao' => 'Pão com manteiga' },
        'almoco' => { 'prato_principal_padrao' => prato, 'prato_principal_vegetariano_estrito' => 'Feijoada vegana',
                      'acompanhamentos' => %w[Arroz Feijão], 'molho_para_salada' => 'Vinagrete' },
        'jantar' => { 'prato_principal_padrao' => 'Sopa de legumes' }
      } }
  end

  def api_com_a_semana
    dias = (0..6).map { |i| dia_da_api(segunda + i, "Prato do dia #{i}") }
    allow(CardapioApi::Cliente).to receive(:semana_vigente).and_return({ 'dias' => dias })
  end

  describe 'GET /cardapio/hoje' do
    it 'é público e marca a refeição em serviço, a encerrada e a que ainda abre' do
      api_com_a_semana
      get cardapio_hoje_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Em serviço', 'Encerrado', 'Abre às 17:00', 'Prato do dia 0',
                                       'Feijoada vegana', 'Pão com manteiga', 'Sopa de legumes')
      expect(response.body).not_to include('Cardápio de reserva')
    end

    it 'mostra guarnições e salada ao lado do prato principal' do
      api_com_a_semana
      get cardapio_hoje_path

      expect(response.body).to include('Guarnições:', 'Arroz, Feijão', 'Salada:', 'Vinagrete')
    end

    it 'mostra a aba ativa e o link para a semana' do
      api_com_a_semana
      get cardapio_hoje_path

      expect(response.body).to include(cardapio_semana_path, 'portal-ativo')
    end
  end

  describe 'GET /cardapio/semana' do
    it 'lista os sete dias e destaca só o dia de hoje' do
      api_com_a_semana
      get cardapio_semana_path

      expect(response).to have_http_status(:ok)
      (0..6).each { |i| expect(response.body).to include("id=\"dia-#{(segunda + i).iso8601}\"", "Prato do dia #{i}") }
      expect(response.body.scan('sg-dia-hoje').size).to eq(1)
      expect(response.body).to match(/sg-dia-hoje" id="dia-2026-11-16"/)
    end
  end

  describe 'reserva quando a API falha' do
    before do
      cardapio = Cardapio.create!(data: Time.zone.today, refeicao: 'almoco')
      cardapio.itens.create!(tipo: 'padrao', item: 'Strogonoff da reserva')
    end

    it 'usa o banco quando o cliente lança ErroApi' do
      allow(CardapioApi::Cliente).to receive(:semana_vigente).and_raise(CardapioApi::ErroApi, 'falhou')
      get cardapio_hoje_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Cardápio de reserva', 'Strogonoff da reserva')
      expect(response.body).not_to include('API', 'falhou')
    end

    it 'usa o banco quando a rede cai' do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('RU_API_TOKEN').and_return('chave-de-teste')
      allow(Net::HTTP).to receive(:start).and_raise(SocketError)
      get cardapio_hoje_path

      expect(response.body).to include('Cardápio de reserva', 'Strogonoff da reserva')
    end

    it 'mostra a semana de hoje mesmo sem a API' do
      allow(CardapioApi::Cliente).to receive(:semana_vigente).and_raise(CardapioApi::ErroApi, 'falhou')
      get cardapio_semana_path

      (0..6).each { |i| expect(response.body).to include("id=\"dia-#{(segunda + i).iso8601}\"") }
    end
  end

  it 'mostra aviso de refeição sem cardápio quando nada foi cadastrado' do
    allow(CardapioApi::Cliente).to receive(:semana_vigente).and_raise(CardapioApi::ErroApi, 'falhou')
    get cardapio_hoje_path

    expect(response.body).to include('ainda não foi disponibilizado')
  end
end
# rubocop:enable Metrics/BlockLength
