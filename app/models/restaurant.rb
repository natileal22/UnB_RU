class Restaurant < ApplicationRecord
  STATUS = %w[ativo inativo].freeze

  has_many :accesses, dependent: :restrict_with_exception
  has_many :catracas, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true
  validates :status, inclusion: { in: STATUS }

  scope :ativos, -> { where(status: "ativo") }

  def ativo?
    status == "ativo"
  end
end
