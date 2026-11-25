require "rails_helper"

RSpec.describe "SessionsController", type: :request do
  let!(:operador) do
    User.create!(name: "Func", matricula: "9000003", password: "SenhaForte123", perfil: "funcionario")
  end
  let!(:estudante) do
    User.create!(name: "Aluno", matricula: "241000077", password: "SenhaForte123", perfil: "estudante")
  end

  describe "POST /login" do
    it "redireciona operador para o ponto de acesso" do
      post login_path, params: { matricula: operador.matricula, password: "SenhaForte123" }

      expect(response).to redirect_to(ponto_acesso_path)
    end

    it "redireciona estudante para a raiz" do
      post login_path, params: { matricula: estudante.matricula, password: "SenhaForte123" }

      expect(response).to redirect_to(root_path)
    end

    it "renderiza o formulário com 422 para credenciais inválidas" do
      post login_path, params: { matricula: operador.matricula, password: "SenhaErrada" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Matrícula ou senha inválidas")
    end

    it "renderiza o formulário com 422 para matrícula inexistente" do
      post login_path, params: { matricula: "000000000", password: "QualquerSenha" }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
