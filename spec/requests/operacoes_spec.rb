require "rails_helper"

RSpec.describe "Operação", type: :request do
  let!(:restaurante) { Restaurant.create!(name: "RU Central") }

  def entrar_como(perfil)
    user = User.create!(name: perfil, matricula: "9000002", password: "SenhaForte123", perfil: perfil)
    post operador_entrar_path, params: { matricula: user.matricula, senha: "SenhaForte123" }
    user
  end

  context "sem login" do
    it "redireciona para a autenticação do operador" do
      get operacao_path

      expect(response).to redirect_to(operador_entrar_path)
    end
  end

  context "com estudante logado" do
    it "retorna 403" do
      estudante = User.create!(name: "Aluno", matricula: "241000088", password: "SenhaForte123",
                               perfil: "estudante")
      post login_path, params: { matricula: estudante.matricula, password: "SenhaForte123" }

      get operacao_path

      expect(response).to have_http_status(:forbidden)
    end
  end

  context "com operador logado" do
    before { entrar_como("funcionario") }

    it "exibe o restaurante quando há restaurant_id válido na sessão" do
      post ponto_acesso_path, params: { restaurant_id: restaurante.id }

      get operacao_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("RU Central")
    end

    it "redireciona para o ponto de acesso quando não há restaurant_id na sessão" do
      get operacao_path

      expect(response).to redirect_to(ponto_acesso_path)
      expect(flash[:alert]).to eq("Selecione um restaurante para continuar")
    end

    it "redireciona para o ponto de acesso quando o restaurante foi inativado após a seleção" do
      post ponto_acesso_path, params: { restaurant_id: restaurante.id }
      restaurante.update!(status: "inativo")

      get operacao_path

      expect(response).to redirect_to(ponto_acesso_path)
      expect(flash[:alert]).to eq("Selecione um restaurante para continuar")
    end
  end
end
