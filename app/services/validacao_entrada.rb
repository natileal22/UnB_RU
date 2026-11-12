# Regra de negócio da Validação de Entrada (issue #6).
# Ordem das checagens: formato -> catraca -> restaurante da sessão -> cadastro -> saldo.
# Toda tentativa gera um registro em accesses, liberada ou negada.
class ValidacaoEntrada
  PRECO = BigDecimal("4.50")
  FORMATO_MATRICULA = /\A\d{9}\z/

  MENSAGENS = {
    "FORMATO_INVALIDO" => "Matrícula com formato inválido",
    "CATRACA_INDISPONIVEL" => "Catraca indisponível",
    "CATRACA_FORA_DO_RESTAURANTE" => "Catraca não pertence ao restaurante selecionado",
    "NAO_CADASTRADO" => "Usuário não cadastrado no sistema",
    "SALDO_INSUFICIENTE" => "Saldo insuficiente para a refeição"
  }.freeze

  Resultado = Struct.new(:liberado, :motivo, keyword_init: true) do
    def liberado?
      liberado
    end

    def mensagem
      liberado ? "Entrada liberada" : MENSAGENS.fetch(motivo)
    end
  end

  def initialize(catraca:, matricula:, restaurante_selecionado_id: nil)
    @catraca = catraca
    @matricula = matricula.to_s.strip
    @restaurante_selecionado_id = restaurante_selecionado_id
  end

  def call
    motivo = motivo_antes_do_saldo
    return negar(motivo) if motivo

    # Débito e registro na MESMA transação: ou acontecem os dois, ou nenhum.
    ActiveRecord::Base.transaction do
      usuario.lock!
      if usuario.saldo < PRECO
        negar("SALDO_INSUFICIENTE")
      else
        usuario.update!(saldo: usuario.saldo - PRECO)
        registrar(resultado: "LIBERADO", valor: PRECO)
        Resultado.new(liberado: true)
      end
    end
  end

  private

  attr_reader :catraca, :matricula, :restaurante_selecionado_id

  def motivo_antes_do_saldo
    return "FORMATO_INVALIDO" unless matricula.match?(FORMATO_MATRICULA)
    return "CATRACA_INDISPONIVEL" unless catraca.disponivel? && catraca.restaurant.ativo?
    return "CATRACA_FORA_DO_RESTAURANTE" if fora_do_restaurante_selecionado?
    return "NAO_CADASTRADO" if usuario.nil?

    nil
  end

  # Só vale quando um funcionário configurou o ponto de acesso (issue #5) nesta sessão.
  def fora_do_restaurante_selecionado?
    restaurante_selecionado_id.present? && catraca.restaurant_id != restaurante_selecionado_id.to_i
  end

  def usuario
    return @usuario if defined?(@usuario)

    @usuario = User.find_by(matricula: matricula, perfil: "estudante")
  end

  def negar(motivo)
    registrar(resultado: "NEGADO", motivo: motivo, valor: 0)
    Resultado.new(liberado: false, motivo: motivo)
  end

  def registrar(resultado:, valor:, motivo: nil)
    Access.create!(
      restaurant: catraca.restaurant,
      catraca: catraca.codigo,
      matricula: matricula,
      user: (usuario if matricula.match?(FORMATO_MATRICULA)),
      resultado: resultado,
      motivo_negacao: motivo,
      valor_cobrado: valor,
      occurred_at: Time.current
    )
  end
end