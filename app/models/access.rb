class Access < ApplicationRecord
  belongs_to :restaurant

  RESULTS = %w[LIBERADO NEGADO].freeze

  validates :catraca, :matricula, :resultado, :occurred_at, presence: true
  validates :resultado, inclusion: { in: RESULTS }

  scope :recent_first, -> { order(occurred_at: :desc) }
end
