class User < ApplicationRecord
  PERFIS = %w[ADMIN FUNCIONARIO ALUNO].freeze

  has_many :accesses, dependent: :nullify

  validates :name, :password, presence: true
  validates :matricula, presence: true, uniqueness: { message: "já cadastrada" },
                        format: { with: /\A\d{9}\z/, message: "inválida", allow_blank: true }
  validates :perfil, inclusion: { in: PERFIS }
  validates :saldo, numericality: { greater_than_or_equal_to: 0 }
  validate :matricula_must_not_be_repeated_digit

  def operador?
    %w[ADMIN FUNCIONARIO].include?(perfil)
  end

  private

  def matricula_must_not_be_repeated_digit
    return unless matricula.present? && matricula.match?(/\A(\d)\1{8}\z/)

    errors.add(:matricula, "inválida")
  end
end
