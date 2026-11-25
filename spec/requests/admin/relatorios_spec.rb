require "rails_helper"

RSpec.describe "Relatório global do administrador", type: :request do
  let!(:darcy) { Restaurant.create!(name: "RU Darcy Ribeiro") }
  let!(:gama) { Restaurant.create!(name: "RU Gama") }

  before do
    allow_any_instance_of(Admin::RelatoriosController).to receive(:session).and_return(role: "Administrador")

    Access.create!(restaurant: darcy, catraca: "CAT-01", matricula: "241012345",
                   resultado: "LIBERADO", occurred_at: Time.zone.parse("2026-10-20"))
    Access.create!(restaurant: darcy, catraca: "CAT-02", matricula: "241012346",
                   resultado: "NEGADO", occurred_at: Time.zone.parse("2026-10-20"))
    Access.create!(restaurant: gama, catraca: "CAT-01", matricula: "241012347",
                   resultado: "LIBERADO", occurred_at: Time.zone.parse("2026-10-21"))
  end

  it "lista todos os acessos" do
    get admin_relatorio_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("241012345", "241012346", "241012347")
  end

  it "filtra por restaurante e resultado" do
    get admin_relatorio_path, params: { restaurant_id: darcy.id, resultado: "NEGADO" }

    expect(response.body).to include("241012346")
    expect(response.body).not_to include("241012345", "241012347")
  end

  it "filtra por período e agrupa por restaurante e catraca" do
    get admin_relatorio_path, params: {
      date_from: "2026-10-20", date_to: "2026-10-20", grouped: "1"
    }

    expect(response.body).to include("CAT-01", "CAT-02", "Quantidade de acessos")
    expect(response.body).not_to include("241012347")
  end

  it "mantém o relatório disponível quando a data inicial não pode ser interpretada" do
    get admin_relatorio_path, params: { date_from: "99" }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("241012345", "241012346", "241012347")
  end

  it "não exibe acessos quando a data final não pode ser interpretada" do
    get admin_relatorio_path, params: { date_to: "99" }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Nenhum acesso encontrado para os filtros informados")
  end

  it "exibe o estado vazio quando nenhum acesso corresponde aos filtros" do
    get admin_relatorio_path, params: { catraca: "CAT-99" }

    expect(response.body).to include("Nenhum acesso encontrado para os filtros informados")
    expect(response.body).not_to include("241012345")
  end

  it "bloqueia o acesso de uma sessão sem perfil de administrador" do
    allow_any_instance_of(Admin::RelatoriosController).to receive(:session).and_return(role: "Funcionário")

    get admin_relatorio_path

    expect(response).to have_http_status(:forbidden)
    expect(response.body).to include("Acesso negado: apenas o Administrador pode realizar esta ação")
    expect(response.body).not_to include("241012345")
  end

  it "bloqueia o acesso sem autenticação" do
    allow_any_instance_of(Admin::RelatoriosController).to receive(:session).and_return({})

    get admin_relatorio_path

    expect(response).to have_http_status(:forbidden)
    expect(response.body).to include("Acesso negado: apenas o Administrador pode realizar esta ação")
    expect(response.body).not_to include("241012345")
  end
end
