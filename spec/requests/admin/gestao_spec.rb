# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
require 'rails_helper'

RSpec.describe 'Admin::Gestao', type: :request do
  let!(:restaurante) do
    Restaurant.create!(name: 'RU Central', localizacao: 'Campus', capacidade: 100, horario_abertura: '11:00',
                       horario_fechamento: '14:00')
  end
  let(:dados) do
    { name: 'RU Gama', localizacao: 'Campus Gama', capacidade: 300, horario_abertura: '11:00',
      horario_fechamento: '14:00' }
  end

  def entrar_como(perfil)
    User.create!(name: perfil, matricula: '9000001', password: 'SenhaForte123', perfil: perfil)
    post operador_entrar_path, params: { matricula: '9000001', senha: 'SenhaForte123' }
  end

  it 'redireciona para a autenticação sem sessão' do
    get admin_restaurantes_path

    expect(response).to redirect_to(operador_entrar_path)
  end

  it 'mostra a listagem ao funcionário sem formulários nem controles de administrador' do
    entrar_como('funcionario')
    get admin_restaurantes_path

    expect(response.body).to include('RU Central')
    expect(response.body).not_to include('new_restaurant', 'Cadastrar Restaurante', 'Remover', 'Inativar')
  end

  it 'nega ao funcionário todas as ações administrativas' do
    entrar_como('funcionario')
    catraca = Catraca.create!(restaurant: restaurante, codigo: 'CAT-01', status: 'inativa')

    [[:get, new_admin_restaurante_path], [:post, admin_restaurantes_path],
     [:delete, admin_restaurante_path(restaurante)], [:patch, inativar_admin_restaurante_path(restaurante)],
     [:get, new_admin_catraca_path], [:delete, admin_catraca_path(catraca)]].each do |metodo, caminho|
      send(metodo, caminho)

      expect(response).to have_http_status(:forbidden)
      expect(response.body).to include('Acesso negado: apenas o Administrador pode realizar esta ação')
    end
    expect(Restaurant.count + Catraca.count).to eq(2)
  end

  context 'como administrador' do
    before { entrar_como('administrador') }

    it 'lista os restaurantes em ordem alfabética' do
      Restaurant.create!(name: 'RU Asa Norte')
      get admin_restaurantes_path

      expect(response.body.index('RU Asa Norte')).to be < response.body.index('RU Central')
    end

    it 'cadastra restaurante válido' do
      post admin_restaurantes_path, params: { restaurant: dados }

      expect(response).to redirect_to(admin_restaurantes_path)
      expect(Restaurant.find_by(name: 'RU Gama').status).to eq('ativo')
    end

    it 'responde 422 com a mensagem quando os dados são inválidos' do
      post admin_restaurantes_path, params: { restaurant: dados.merge(capacidade: '0') }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Capacidade inválida: informe um número inteiro entre 1 e 5000')
    end

    it 'atualiza e inativa com cascata' do
      Catraca.create!(restaurant: restaurante, codigo: 'CAT-01')
      patch admin_restaurante_path(restaurante), params: { restaurant: { capacidade: 800 } }
      patch inativar_admin_restaurante_path(restaurante)

      expect(restaurante.reload).to have_attributes(capacidade: 800, status: 'inativo')
      expect(restaurante.catracas.first.status).to eq('inativa')
    end

    it 'reativa o restaurante' do
      restaurante.update!(status: 'inativo')
      patch ativar_admin_restaurante_path(restaurante)

      expect(restaurante.reload.status).to eq('ativo')
    end

    it 'remove restaurante sem catracas e bloqueia quando há catracas' do
      outro = Restaurant.create!(name: 'RU Vazio')
      delete admin_restaurante_path(outro)
      expect(Restaurant.exists?(outro.id)).to be(false)

      Catraca.create!(restaurant: restaurante, codigo: 'CAT-01', status: 'inativa')
      delete admin_restaurante_path(restaurante)
      expect(Restaurant.exists?(restaurante.id)).to be(true)
      expect(flash[:alert]).to include('catracas vinculadas')
    end

    it 'cadastra catraca com responsável funcionário' do
      func = User.create!(name: 'Carlos', matricula: '9000002', password: 'SenhaForte123', perfil: 'funcionario')
      post admin_catracas_path, params: { catraca: { codigo: 'CAT-01', restaurant_id: restaurante.id,
                                                     status: 'ativa', responsavel_id: func.id } }

      expect(Catraca.find_by(codigo: 'CAT-01').responsavel).to eq(func)
    end

    it 'rejeita catraca ativa em restaurante inativo' do
      restaurante.update!(status: 'inativo')
      post admin_catracas_path, params: { catraca: { codigo: 'CAT-09', restaurant_id: restaurante.id,
                                                     status: 'ativa' } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(Catraca.count).to eq(0)
    end

    it 'não remove catraca ativa e remove inativa' do
      ativa = Catraca.create!(restaurant: restaurante, codigo: 'CAT-01')
      delete admin_catraca_path(ativa)
      expect(Catraca.exists?(ativa.id)).to be(true)

      ativa.update!(status: 'inativa')
      delete admin_catraca_path(ativa)
      expect(Catraca.exists?(ativa.id)).to be(false)
    end
  end
end
# rubocop:enable Metrics/BlockLength
