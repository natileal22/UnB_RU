require "rails_helper"

RSpec.describe Catraca, type: :model do
  let(:restaurante) { Restaurant.create!(name: "RU Central") }

  it "exige código único dentro do mesmo restaurante" do
    described_class.create!(restaurant: restaurante, codigo: "CAT-01")
    repetida = described_class.new(restaurant: restaurante, codigo: "CAT-01")

    expect(repetida).not_to be_valid
  end

  it "só fica disponível quando está ativa" do
    expect(described_class.new(status: "ativa")).to be_disponivel
    expect(described_class.new(status: "em_manutencao")).not_to be_disponivel
  end
end
