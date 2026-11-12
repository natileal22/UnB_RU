class Access < ApplicationRecord
  RESULTS = %w[LIBERADO NEGADO].freeze
  MOTIVOS = %w[FORMATO_INVALIDO NAO_CADASTRADO SALDO_INSUFICIENTE CATRACA_INDISPONIVEL
               CATRACA_FORA_DO_RESTAURANTE].freeze

  belongs_to :restaurant
  belongs_to :user, optional: true

  validates :catraca, :resultado, :occurred_at, presence: true
  # Matrícula em branco é registrada como tentativa com formato inválido.
  validates :matricula, presence: true, unless: -> { motivo_negacao == "FORMATO_INVALIDO" }
  validates :resultado, inclusion: { in: RESULTS }
  validates :motivo_negacao, inclusion: { in: MOTIVOS }, allow_nil: true

  scope :recent_first, -> { order(occurred_at: :desc) }
end