require "rails_helper"

RSpec.describe Restaurant, type: :model do
  it "requires a unique name" do
    described_class.create!(name: "RU Darcy Ribeiro")
    duplicate = described_class.new(name: "RU Darcy Ribeiro")

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:name]).to include("já está em uso")
  end
end
