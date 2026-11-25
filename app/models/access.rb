# frozen_string_literal: true

# Model que registra cada tentativa de entrada em uma catraca (issue #6).
#
# Toda validação — liberada ou negada — gera um +Access+.
# O débito do saldo e a criação do +Access+ ocorrem na mesma transação quando liberado.
class Access < ApplicationRecord
  # Resultados possíveis de uma tentativa de entrada.
  RESULTS = %w[LIBERADO NEGADO].freeze

  # Motivos de negação reconhecidos pelo sistema.
  MOTIVOS = %w[FORMATO_INVALIDO NAO_CADASTRADO SALDO_INSUFICIENTE CATRACA_INDISPONIVEL
               CATRACA_FORA_DO_RESTAURANTE].freeze

  belongs_to :restaurant
  belongs_to :user, optional: true

  validates :catraca, :resultado, :occurred_at, presence: true
  # Matrícula em branco é registrada como tentativa com formato inválido.
  validates :matricula, presence: true, unless: -> { motivo_negacao == 'FORMATO_INVALIDO' }
  validates :resultado, inclusion: { in: RESULTS }
  validates :motivo_negacao, inclusion: { in: MOTIVOS }, allow_nil: true

  # Retorna os registros em ordem decrescente de horário.
  scope :recent_first, -> { order(occurred_at: :desc) }
end
