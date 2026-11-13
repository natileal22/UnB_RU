require "rails_helper"

RSpec.describe "Configuração do ponto de acesso", type: :request do
  let!(:ativo) { Restaurant.create!(name: "RU Central") }
  let!(:inativo) { Restaurant.create!(name: "RU FGA", status: "inativo") }

  def entrar_como(perfil)
    if perfil == "estudante"
      User.create!(name: "Aluno", matricula: "241000099", password: "SenhaForte123", perfil: perfil)
      post login_path, params: { matricula: "241000099", password: "SenhaForte123" }
    else
      User.create!(name: perfil, matricula: "9000001", password: "SenhaForte123", perfil: perfil)
      post operador_entrar_path, params: { matricula: "9000001", senha: "SenhaForte123" }
    end
  end

  it "redireciona para a autenticação do operador quando não há sessão" do
    get ponto_acesso_path

    expect(response).to redirect_to(operador_entrar_path)
  end

  it "nega acesso a alunos" do
    entrar_como("estudante")
    get ponto_acesso_path

    expect(response).to have_http_status(:forbidden)
    expect(response.body).to include("apenas Funcionários e Administradores")
  end

  it "lista apenas restaurantes ativos" do
    entrar_como("funcionario")
    get ponto_acesso_path

    expect(response.body).to include("RU Central")
    expect(response.body).not_to include("RU FGA")
  end

  it "guarda o restaurante na sessão e abre a operação" do
    entrar_como("administrador")
    post ponto_acesso_path, params: { restaurant_id: ativo.id }

    expect(response).to redirect_to(operacao_path)
    expect(session[:restaurant_id]).to eq(ativo.id)
  end

  it "exige a escolha de um restaurante" do
    entrar_como("funcionario")
    post ponto_acesso_path, params: { restaurant_id: "" }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("Selecione um restaurante para continuar")
  end

  it "recusa restaurante inativo enviado diretamente" do
    entrar_como("funcionario")
    post ponto_acesso_path, params: { restaurant_id: inativo.id }

    expect(response.body).to include("Restaurante indisponível para operação")
    expect(session[:restaurant_id]).to be_nil
  end
end
