class Catraca < ApplicationRecord
  STATUS = %w[ativa inativa em_manutencao].freeze

  belongs_to :restaurant

  validates :codigo, presence: true, uniqueness: { scope: :restaurant_id }
  validates :status, inclusion: { in: STATUS }

  def disponivel?
    status == "ativa"
  end
end