# frozen_string_literal: true

# restaurante universitario com dados de gestao validados so no contexto gestao
class Restaurant < ApplicationRecord
  STATUS = %w[ativo inativo].freeze
  MSG_CAPACIDADE = 'Capacidade inválida: informe um número inteiro entre 1 e 5000'

  has_many :accesses, dependent: :restrict_with_exception
  has_many :catracas, dependent: :restrict_with_exception

  validates :name, presence: { message: 'Nome do restaurante é obrigatório' },
                   uniqueness: { case_sensitive: false, message: 'Já existe um restaurante com este nome' }
  validates :status, inclusion: { in: STATUS }
  validates :localizacao, presence: { message: 'Localização do restaurante é obrigatória' }, on: :gestao
  validates :capacidade, numericality: { only_integer: true, in: 1..5000, message: MSG_CAPACIDADE }, on: :gestao
  validate :horarios_de_funcionamento, on: :gestao

  scope :ativos, -> { where(status: 'ativo') }

  def ativo?
    status == 'ativo'
  end

  def status_rotulo
    status.capitalize
  end

  def slug
    name.parameterize
  end

  def motivo_bloqueio_remocao
    return unless catracas.exists? || accesses.exists?

    'Não é possível remover um restaurante com catracas vinculadas. ' \
      'Remova as catracas antes ou apenas inative o restaurante'
  end

  private

  def horarios_de_funcionamento
    abertura = checar_horario(:horario_abertura, 'abertura')
    fechamento = checar_horario(:horario_fechamento, 'fechamento')
    return unless abertura && fechamento && abertura >= fechamento

    errors.add(:horario_abertura, 'O horário de abertura deve ser anterior ao horário de fechamento')
  end

  # devolve o horario valido ou nil e ja registra o erro
  def checar_horario(campo, nome)
    bruto = public_send("#{campo}_before_type_cast")
    valor = public_send(campo)
    return valor if valor

    errors.add(campo, "Horário de #{nome} é #{bruto.to_s.strip.empty? ? 'obrigatório' : 'inválido'}")
    nil
  end
end
