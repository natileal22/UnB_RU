require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) do
    described_class.new(name: "Ana Silva", matricula: "123456789", password: "SenhaForte123")
  end

  it { is_expected.to be_valid }

  it "rejects a matrícula with the wrong format" do
    user.matricula = "123"

    expect(user).not_to be_valid
    expect(user.errors[:matricula]).to include("inválida")
  end

  it "rejects a matrícula made of repeated digits" do
    user.matricula = "999999999"

    expect(user).not_to be_valid
    expect(user.errors[:matricula]).to include("inválida")
  end

  it "requires a unique matrícula" do
    described_class.create!(name: "Ana Silva", matricula: "123456789", password: "SenhaForte123")
    duplicate = described_class.new(name: "Bruno Oliveira", matricula: "123456789", password: "AcessoRU456")

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:matricula]).to include("já cadastrada")
  end
end
