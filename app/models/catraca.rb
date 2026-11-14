# frozen_string_literal: true

# catraca de um restaurante com responsavel opcional
class Catraca < ApplicationRecord
  STATUS = %w[ativa inativa em_manutencao].freeze

  belongs_to :restaurant
  belongs_to :responsavel, class_name: 'User', optional: true

  scope :vinculadas_a, ->(usuario) { where(responsavel_id: usuario.id) }

  validates :codigo, presence: true, uniqueness: { scope: :restaurant_id }
  validates :status, inclusion: { in: STATUS }

  def disponivel?
    status == 'ativa'
  end
end
