class User < ApplicationRecord
  validates :name, :password, presence: true
  validates :matricula, presence: true, uniqueness: { message: "já cadastrada" },
                        format: { with: /\A\d{9}\z/, message: "inválida" }
  validate :matricula_must_not_be_repeated_digit

  private

  def matricula_must_not_be_repeated_digit
    return unless matricula.present? && matricula.match?(/\A(\d)\1{8}\z/)

    errors.add(:matricula, "inválida")
  end
end
