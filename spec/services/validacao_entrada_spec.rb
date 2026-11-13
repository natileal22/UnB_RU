require "rails_helper"

RSpec.describe ValidacaoEntrada do
  let(:restaurante) { Restaurant.create!(name: "RU Central") }
  let(:catraca) { Catraca.create!(restaurant: restaurante, codigo: "CAT-01") }
  let!(:estudante) do
    User.create!(name: "Ana", matricula: "241012345", password: "SenhaForte123", saldo: 5, perfil: "estudante")
  end

  def validar(matricula, catraca: self.catraca, restaurante_selecionado_id: nil)
    described_class.new(catraca: catraca, matricula: matricula,
                        restaurante_selecionado_id: restaurante_selecionado_id).call
  end

  it "libera, debita R$ 4,50 e registra o acesso" do
    resultado = validar("241012345")

    expect(resultado).to be_liberado
    expect(estudante.reload.saldo).to eq(BigDecimal("0.50"))
    expect(Access.last).to have_attributes(resultado: "LIBERADO", motivo_negacao: nil,
                                           valor_cobrado: BigDecimal("4.50"), user: estudante)
  end

  it "libera com saldo exatamente igual ao preço (valor limite)" do
    estudante.update!(saldo: BigDecimal("4.50"))

    expect(validar("241012345")).to be_liberado
    expect(estudante.reload.saldo).to eq(0)
  end

  it "nega com saldo um centavo abaixo do preço e não debita" do
    estudante.update!(saldo: BigDecimal("4.49"))

    resultado = validar("241012345")

    expect(resultado.motivo).to eq("SALDO_INSUFICIENTE")
    expect(resultado.mensagem).to eq("Saldo insuficiente para a refeição")
    expect(estudante.reload.saldo).to eq(BigDecimal("4.49"))
  end

  ["2410123", "24101234", "2410123456", "ABCDEFGHI", "241#12345", ""].each do |matricula|
    it "nega a matrícula #{matricula.inspect} por formato inválido" do
      resultado = validar(matricula)

      expect(resultado.motivo).to eq("FORMATO_INVALIDO")
      expect(Access.last).to have_attributes(resultado: "NEGADO", user: nil, valor_cobrado: 0)
    end
  end

  it "nega matrícula que não está cadastrada" do
    expect(validar("241099999").motivo).to eq("NAO_CADASTRADO")
  end

  it "nega a matrícula SIAPE de funcionário (7 dígitos) por formato inválido" do
    User.create!(name: "Func", matricula: "2410001", password: "x", perfil: "funcionario", saldo: 10)

    expect(validar("2410001").motivo).to eq("FORMATO_INVALIDO")
  end

  %w[inativa em_manutencao].each do |status|
    it "nega quando a catraca está #{status}" do
      catraca.update!(status: status)

      expect(validar("241012345").motivo).to eq("CATRACA_INDISPONIVEL")
      expect(estudante.reload.saldo).to eq(5)
    end
  end

  it "nega quando a catraca não é do restaurante selecionado pelo funcionário" do
    outro = Restaurant.create!(name: "RU FGA")

    resultado = validar("241012345", restaurante_selecionado_id: outro.id)

    expect(resultado.motivo).to eq("CATRACA_FORA_DO_RESTAURANTE")
  end

  it "libera quando a catraca é do restaurante selecionado" do
    expect(validar("241012345", restaurante_selecionado_id: restaurante.id)).to be_liberado
  end

  it "registra todas as tentativas, liberadas e negadas" do
    expect { validar("241012345"); validar("123") }.to change(Access, :count).by(2)
  end
end
