# frozen_string_literal: true

# catraca de um restaurante com responsavel opcional
class Catraca < ApplicationRecord
  STATUS = %w[ativa inativa em_manutencao].freeze
  STATUS_ROTULOS = { 'ativa' => 'Ativa', 'inativa' => 'Inativa', 'em_manutencao' => 'Em Manutenção' }.freeze
  FORMATO_CODIGO = /\A[A-Za-z0-9_-]+\z/
  MSG_HORARIO_INCOMPLETO = 'Informe os horários de abertura e fechamento da catraca juntos'
  MSG_HORARIO_INVERTIDO = 'O horário de abertura da catraca deve ser anterior ao horário de fechamento'

  belongs_to :restaurant
  belongs_to :responsavel, class_name: 'User', optional: true

  scope :vinculadas_a, ->(usuario) { where(responsavel_id: usuario.id) }

  validates :codigo, presence: { message: 'Código da catraca é obrigatório' },
                     length: { maximum: 20, message: 'Código da catraca deve ter no máximo 20 caracteres' },
                     format: { with: FORMATO_CODIGO, allow_blank: true,
                               message: 'Código da catraca contém caracteres inválidos' },
                     uniqueness: { scope: :restaurant_id, case_sensitive: false,
                                   message: 'Já existe uma catraca com este código neste restaurante' }
  validates :status, inclusion: { in: STATUS }
  validate :responsavel_operador
  validate :historico_preservado, on: :gestao
  validate :restaurante_ativo_para_ativar, on: :gestao
  validate :horarios_de_funcionamento, on: :gestao

  def disponivel?
    status == 'ativa'
  end

  def status_rotulo
    STATUS_ROTULOS.fetch(status)
  end

  def slug
    "#{restaurant.slug}--#{codigo.parameterize}"
  end

  def acessos
    Access.where(restaurant_id: restaurant_id, catraca: codigo)
  end

  def motivo_bloqueio_remocao
    return 'Não é possível remover uma catraca Ativa. Inative a catraca antes de removê-la' if disponivel?

    return unless preso?

    'Não é possível remover uma catraca com responsável ou registros de acesso. Ela só pode ficar inativa'
  end

  # com responsavel ou acessos a catraca so pode ficar inativa
  def preso?
    responsavel_id.present? || acessos.exists?
  end

  private

  def responsavel_operador
    return if responsavel.nil? || responsavel.operador_autorizado?

    errors.add(:responsavel, 'Responsável deve ser funcionário ou administrador')
  end

  # os acessos ligam por restaurante e codigo em texto entao mudar um dos dois orfaria o historico
  def historico_preservado
    return if new_record? || !(codigo_changed? || restaurant_id_changed?)
    return unless Access.where(restaurant_id: restaurant_id_was, catraca: codigo_was).exists?

    errors.add(:codigo, 'Não é possível alterar o código ou o restaurante de uma catraca com registros de acesso')
  end

  def restaurante_ativo_para_ativar
    return unless disponivel? && restaurant && !restaurant.ativo?

    errors.add(:status, 'Não é possível ativar a catraca porque o restaurante está Inativo')
  end

  # horario e opcional mas vem os dois juntos e a abertura antes do fechamento
  def horarios_de_funcionamento
    return errors.add(:horario_abertura, MSG_HORARIO_INCOMPLETO) if horario_incompleto?

    abertura = checar_horario(:horario_abertura, 'abertura')
    fechamento = checar_horario(:horario_fechamento, 'fechamento')
    return unless abertura && fechamento && abertura >= fechamento

    errors.add(:horario_abertura, MSG_HORARIO_INVERTIDO)
  end

  def horario_incompleto?
    preenchido?(:horario_abertura) != preenchido?(:horario_fechamento)
  end

  def preenchido?(campo)
    public_send("#{campo}_before_type_cast").to_s.strip.present?
  end

  # devolve o horario valido ou nil e registra o erro quando veio texto que nao e hora
  def checar_horario(campo, nome)
    return public_send(campo) if public_send(campo) || !preenchido?(campo)

    errors.add(campo, "Horário de #{nome} da catraca é inválido")
    nil
  end
end
