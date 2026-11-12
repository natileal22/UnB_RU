require "rails_helper"

RSpec.describe "Catraca", type: :request do
  let(:catraca) { Catraca.create!(restaurant: Restaurant.create!(name: "RU Central"), codigo: "CAT-01") }

  before { User.create!(name: "Ana", matricula: "241012345", password: "SenhaForte123", saldo: 5, perfil: "estudante") }

  it "libera a entrada" do
    post entrada_catraca_path(catraca), params: { matricula: "241012345" }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Entrada liberada")
  end

  it "mostra o motivo quando nega" do
    post entrada_catraca_path(catraca), params: { matricula: "abc" }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("Matrícula com formato inválido")
  end
end
