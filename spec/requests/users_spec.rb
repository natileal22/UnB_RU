require "rails_helper"

RSpec.describe "User registration", type: :request do
  let(:valid_params) do
    { user: { name: "Ana Silva", matricula: "123456789", password: "SenhaForte123" } }
  end

  it "creates a user and redirects to authentication" do
    post users_path, params: valid_params

    expect(response).to redirect_to(login_path)
    expect(flash[:notice]).to eq("Cadastro realizado com sucesso")
    expect(User.find_by(matricula: "123456789").authenticate("SenhaForte123")).to be_truthy
  end

  it "keeps the form and reports missing required fields" do
    post users_path, params: { user: {} }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Preencha todos os campos obrigatórios")
    expect(User.count).to eq(0)
  end

  it "reports an invalid matrícula" do
    post users_path, params: {
      user: { name: "Ana Silva", matricula: "123", password: "SenhaForte123" }
    }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Matrícula inválida")
    expect(User.count).to eq(0)
  end

  it "reports a duplicate matrícula" do
    User.create!(name: "Ana Silva", matricula: "123456789", password: "SenhaForte123")

    post users_path, params: valid_params

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Matrícula já cadastrada")
    expect(User.count).to eq(1)
  end
end
