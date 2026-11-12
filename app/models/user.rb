class User < ApplicationRecord
  has_secure_password

  # Permite usar tanto :nome (MER) quanto :name (Issue #1 e specs existentes)
  alias_attribute :name, :nome

  PERFIS = %w[estudante funcionario administrador].freeze

  validates :name, presence: true
  validates :perfil, presence: true, inclusion: { in: PERFIS }
  validates :matricula, presence: true, uniqueness: { message: 'já cadastrada' }

  # Estudantes: 9 dígitos (UnB)
  validates :matricula,
            format: { with: /\A\d{9}\z/, message: 'inválida', allow_blank: true },
            if: -> { perfil == 'estudante' }

  # Funcionários e administradores: 7 dígitos (SIAPE)
  validates :matricula,
            format: { with: /\A\d{7}\z/, message: 'inválida', allow_blank: true },
            if: :operador_autorizado?

  validate :matricula_must_not_be_repeated_digit

  def operador_autorizado?
    %w[funcionario administrador].include?(perfil)
  end

  private

  def matricula_must_not_be_repeated_digit
    return if matricula.blank?

    # Bloqueia sequências totalmente repetidas de qualquer tamanho (ex: 1111111 ou 111111111)
    return unless matricula.match?(/\A(\d)\1+\z/)

    errors.add(:matricula, 'inválida')
  end
end
