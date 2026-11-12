require 'rails_helper'

RSpec.describe 'Operador::Sessoes', type: :request do
  let!(:funcionario) do
    User.create!(
      nome: 'Operador RU',
      matricula: '1234567',
      password: 'SenhaCorreta123',
      perfil: 'funcionario'
    )
  end

  describe 'GET /operador/entrar' do
    it 'renders the operator login page' do
      get operador_entrar_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Autenticação do Operador')
    end
  end

  describe 'POST /operador/entrar' do
    it 'authenticates valid operator credentials and redirects' do
      post operador_entrar_path, params: { matricula: '1234567', senha: 'SenhaCorreta123' }
      expect(response).to redirect_to(admin_restaurantes_path)
      expect(session[:user_id]).to eq(funcionario.id)
    end

    it 'rejects wrong password with invalid credentials error' do
      post operador_entrar_path, params: { matricula: '1234567', senha: 'SenhaErrada' }
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Credenciais inválidas')
      expect(session[:user_id]).to be_nil
    end

    it 'rejects blank fields with required fields alert' do
      post operador_entrar_path, params: { matricula: '', senha: '' }
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Preencha todos os campos obrigatórios')
    end

    it 'rejects a student trying to log in as operator' do
      User.create!(
        nome: 'Aluno UnB',
        matricula: '123456789',
        password: 'SenhaAluno123',
        perfil: 'estudante'
      )
      post operador_entrar_path, params: { matricula: '123456789', senha: 'SenhaAluno123' }
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Credenciais inválidas')
      expect(session[:user_id]).to be_nil
    end
  end
end
