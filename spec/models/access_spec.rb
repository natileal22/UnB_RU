require "rails_helper"

RSpec.describe Access, type: :model do
  subject(:access) do
    described_class.new(
      restaurant: Restaurant.new(name: "RU Darcy Ribeiro"),
      catraca: "CAT-01",
      matricula: "241012345",
      resultado: "LIBERADO",
      occurred_at: Time.zone.parse("2026-10-20")
    )
  end

  it { is_expected.to be_valid }

  it "accepts only supported results" do
    access.resultado = "PENDENTE"

    expect(access).not_to be_valid
    expect(access.errors.details[:resultado]).to include(a_hash_including(error: :inclusion))
  end
end
