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

  # diz se a catraca esta ativa
  # args: nenhum
  # retorna: true quando o status e ativa
  # efeito: nenhum
  def disponivel?
    status == 'ativa'
  end

  # nome do status para a tela
  # args: nenhum
  # retorna: Ativa, Inativa ou Em Manutencao
  # efeito: nenhum
  def status_rotulo
    STATUS_ROTULOS.fetch(status)
  end

  # identificador da catraca usado nos ids da tela
  # args: nenhum
  # retorna: texto com o slug do restaurante e o codigo
  # efeito: nenhum
  def slug
    "#{restaurant.slug}--#{codigo.parameterize}"
  end

  # acessos registrados nesta catraca, que liga por restaurante e codigo em texto
  # args: nenhum
  # retorna: relacao de Access
  # efeito: so le o banco
  def acessos
    Access.where(restaurant_id: restaurant_id, catraca: codigo)
  end

  # explica por que a catraca nao pode ser removida
  # args: nenhum
  # retorna: mensagem (String) ou nil quando pode remover
  # efeito: so le o banco
  def motivo_bloqueio_remocao
    return 'Não é possível remover uma catraca Ativa. Inative a catraca antes de removê-la' if disponivel?

    return unless preso?

    'Não é possível remover uma catraca com responsável ou registros de acesso. Ela só pode ficar inativa'
  end

  # com responsavel ou acessos a catraca so pode ficar inativa
  # args: nenhum
  # retorna: true quando tem responsavel ou acessos
  # efeito: so le o banco
  def preso?
    responsavel_id.present? || acessos.exists?
  end

  private

  # validacao: o responsavel deve ser funcionario ou administrador
  # args: nenhum
  # retorna: nada, registra o erro em responsavel quando invalido
  # efeito: acrescenta erro ao registro
  def responsavel_operador
    return if responsavel.nil? || responsavel.operador_autorizado?

    errors.add(:responsavel, 'Responsável deve ser funcionário ou administrador')
  end

  # validacao do contexto gestao: codigo e restaurante nao mudam com acessos
  # args: nenhum
  # retorna: nada, registra o erro em codigo quando invalido
  # efeito: acrescenta erro ao registro e le o banco
  def historico_preservado
    return if new_record? || !(codigo_changed? || restaurant_id_changed?)
    return unless Access.where(restaurant_id: restaurant_id_was, catraca: codigo_was).exists?

    errors.add(:codigo, 'Não é possível alterar o código ou o restaurante de uma catraca com registros de acesso')
  end

  # validacao do contexto gestao: catraca ativa so em restaurante ativo
  # args: nenhum
  # retorna: nada, registra o erro em status quando invalido
  # efeito: acrescenta erro ao registro
  def restaurante_ativo_para_ativar
    return unless disponivel? && restaurant && !restaurant.ativo?

    errors.add(:status, 'Não é possível ativar a catraca porque o restaurante está Inativo')
  end

  # validacao do contexto gestao: horarios juntos, reais e abertura antes do fechamento
  # args: nenhum
  # retorna: nada, registra o erro no horario quando invalido
  # efeito: acrescenta erro ao registro
  def horarios_de_funcionamento
    return errors.add(:horario_abertura, MSG_HORARIO_INCOMPLETO) if horario_incompleto?

    abertura = checar_horario(:horario_abertura, 'abertura')
    fechamento = checar_horario(:horario_fechamento, 'fechamento')
    return unless abertura && fechamento && abertura >= fechamento

    errors.add(:horario_abertura, MSG_HORARIO_INVERTIDO)
  end

  # diz se so um dos dois horarios foi preenchido
  # args: nenhum
  # retorna: true quando um esta preenchido e o outro nao
  # efeito: nenhum
  def horario_incompleto?
    preenchido?(:horario_abertura) != preenchido?(:horario_fechamento)
  end

  # diz se o texto digitado em um horario nao esta vazio
  # args: campo (Symbol)
  # retorna: true quando ha texto
  # efeito: nenhum
  def preenchido?(campo)
    public_send("#{campo}_before_type_cast").to_s.strip.present?
  end

  # valida um dos horarios
  # args: campo (Symbol) e nome (String) para a mensagem
  # retorna: o horario (Time) valido, ou nil quando vazio ou invalido
  # efeito: acrescenta erro ao registro quando o texto nao e uma hora
  def checar_horario(campo, nome)
    return public_send(campo) if public_send(campo) || !preenchido?(campo)

    errors.add(campo, "Horário de #{nome} da catraca é inválido")
    nil
  end
end
