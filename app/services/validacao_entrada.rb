# Serviço que encapsula a regra de negócio da Validação de Entrada (issue #6).
#
# Ordem das checagens: formato -> catraca -> restaurante da sessão -> cadastro -> saldo.
# Toda tentativa gera um registro em +accesses+, liberada ou negada.
class ValidacaoEntrada
  # Preço fixo cobrado por refeição.
  PRECO = BigDecimal("4.50")

  # Expressão regular que valida os 9 dígitos da matrícula de estudante.
  FORMATO_MATRICULA = /\A\d{9}\z/

  # Mensagens de negação indexadas pelo motivo, usadas por +Resultado#mensagem+.
  MENSAGENS = {
    "FORMATO_INVALIDO" => "Matrícula com formato inválido",
    "CATRACA_INDISPONIVEL" => "Catraca indisponível",
    "CATRACA_FORA_DO_RESTAURANTE" => "Catraca não pertence ao restaurante selecionado",
    "NAO_CADASTRADO" => "Usuário não cadastrado no sistema",
    "SALDO_INSUFICIENTE" => "Saldo insuficiente para a refeição"
  }.freeze

  # Struct de retorno do serviço que carrega o resultado de uma tentativa de entrada.
  Resultado = Struct.new(:liberado, :motivo, keyword_init: true) do
    # Indica se a entrada foi liberada.
    #
    # ==== Argumentos
    # Nenhum.
    #
    # ==== Retorno
    # +true+ quando liberado, +false+ quando negado.
    #
    # ==== Efeitos colaterais
    # Nenhum.
    def liberado?
      liberado
    end

    # Retorna a mensagem legível para exibição ao usuário.
    #
    # ==== Argumentos
    # Nenhum.
    #
    # ==== Retorno
    # A string "Entrada liberada" quando liberado, ou a mensagem de MENSAGENS correspondente ao motivo.
    #
    # ==== Efeitos colaterais
    # Nenhum.
    def mensagem
      liberado ? "Entrada liberada" : MENSAGENS.fetch(motivo)
    end
  end

  # Cria o serviço com os dados necessários para a validação.
  #
  # ==== Argumentos
  # * +catraca+ — objeto Catraca já carregado pelo controller.
  # * +matricula+ — string com a matrícula informada pelo usuário (será normalizada).
  # * +restaurante_selecionado_id+ — id do restaurante na sessão do operador; +nil+ quando não configurado.
  #
  # ==== Retorno
  # Uma instância de ValidacaoEntrada pronta para chamar +call+.
  #
  # ==== Efeitos colaterais
  # Nenhum.
  def initialize(catraca:, matricula:, restaurante_selecionado_id: nil)
    @catraca = catraca
    @matricula = matricula.to_s.strip
    @restaurante_selecionado_id = restaurante_selecionado_id
  end

  # Executa a validação e retorna o resultado.
  #
  # ==== Argumentos
  # Nenhum. Usa a catraca, a matrícula e o restaurante recebidos no +initialize+.
  #
  # ==== Retorno
  # Um +ValidacaoEntrada::Resultado+: +liberado?+ é +true+ quando a entrada foi liberada,
  # ou +false+ com o +motivo+ da negação (+FORMATO_INVALIDO+, +CATRACA_INDISPONIVEL+,
  # +CATRACA_FORA_DO_RESTAURANTE+, +NAO_CADASTRADO+ ou +SALDO_INSUFICIENTE+).
  #
  # ==== Efeitos colaterais
  # Grava um registro em +accesses+ em toda tentativa.
  # Quando libera, debita +PRECO+ do saldo do usuário na mesma transação.
  def call
    motivo = motivo_antes_do_saldo
    return negar(motivo) if motivo

    debitar_e_liberar
  end

  private

  attr_reader :catraca, :matricula, :restaurante_selecionado_id

  # Verifica todos os motivos de negação que não dependem de consulta ao saldo.
  #
  # ==== Argumentos
  # Nenhum.
  #
  # ==== Retorno
  # A string do motivo de negação, ou +nil+ quando não há impedimento.
  #
  # ==== Efeitos colaterais
  # Nenhum.
  def motivo_antes_do_saldo
    return "FORMATO_INVALIDO" unless matricula.match?(FORMATO_MATRICULA)
    return "CATRACA_INDISPONIVEL" unless catraca.disponivel? && catraca.restaurant.ativo?
    return "CATRACA_FORA_DO_RESTAURANTE" if fora_do_restaurante_selecionado?
    return "NAO_CADASTRADO" if usuario.nil?

    nil
  end

  # Verifica se a catraca não pertence ao restaurante configurado na sessão do operador.
  # Só vale quando um funcionário configurou o ponto de acesso (issue #5) nesta sessão.
  #
  # ==== Argumentos
  # Nenhum.
  #
  # ==== Retorno
  # +true+ quando a catraca é de outro restaurante, +false+ caso contrário ou sem sessão configurada.
  #
  # ==== Efeitos colaterais
  # Nenhum.
  def fora_do_restaurante_selecionado?
    restaurante_selecionado_id.present? && catraca.restaurant_id != restaurante_selecionado_id.to_i
  end

  # Busca e memoriza o estudante com a matrícula informada.
  #
  # ==== Argumentos
  # Nenhum.
  #
  # ==== Retorno
  # O objeto +User+ com perfil "estudante", ou +nil+ se não cadastrado.
  #
  # ==== Efeitos colaterais
  # Nenhum.
  def usuario
    return @usuario if defined?(@usuario)

    @usuario = User.find_by(matricula: matricula, perfil: "estudante")
  end

  # Executa o débito e o registro de liberação dentro de uma transação atômica.
  # Débito e registro acontecem os dois, ou nenhum.
  #
  # ==== Argumentos
  # Nenhum.
  #
  # ==== Retorno
  # Um +Resultado+ com +liberado: true+ ou +liberado: false, motivo: "SALDO_INSUFICIENTE"+.
  #
  # ==== Efeitos colaterais
  # Grava um registro em +accesses+. Quando libera, debita +PRECO+ do saldo do usuário.
  def debitar_e_liberar
    ActiveRecord::Base.transaction do
      usuario.lock!
      usuario.saldo < PRECO ? negar("SALDO_INSUFICIENTE") : liberar
    end
  end

  # Debita o saldo e grava o registro de liberação.
  #
  # ==== Argumentos
  # Nenhum.
  #
  # ==== Retorno
  # Um +Resultado+ com +liberado: true+.
  #
  # ==== Efeitos colaterais
  # Atualiza o saldo do usuário e grava um registro LIBERADO em +accesses+.
  def liberar
    usuario.update!(saldo: usuario.saldo - PRECO)
    registrar(resultado: "LIBERADO", valor: PRECO)
    Resultado.new(liberado: true)
  end

  # Grava o registro de negação e retorna o resultado correspondente.
  #
  # ==== Argumentos
  # * +motivo+ — string com o código do motivo de negação (uma das chaves de +MOTIVOS+).
  #
  # ==== Retorno
  # Um +Resultado+ com +liberado: false+ e o +motivo+ informado.
  #
  # ==== Efeitos colaterais
  # Grava um registro NEGADO em +accesses+ com +valor_cobrado: 0+.
  def negar(motivo)
    registrar(resultado: "NEGADO", motivo: motivo, valor: 0)
    Resultado.new(liberado: false, motivo: motivo)
  end

  # Persiste o registro de acesso no banco.
  #
  # ==== Argumentos
  # * +resultado+ — "LIBERADO" ou "NEGADO".
  # * +valor+ — valor cobrado (BigDecimal); zero quando negado.
  # * +motivo+ — código do motivo de negação; +nil+ quando liberado.
  #
  # ==== Retorno
  # O objeto +Access+ criado.
  #
  # ==== Efeitos colaterais
  # Insere uma linha em +accesses+.
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
