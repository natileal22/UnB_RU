# frozen_string_literal: true

# extrato de recargas e historico de refeicoes do proprio estudante da issue 3
class ExtratoHistorico
  Resultado = Struct.new(:recargas, :refeicoes, :erro, keyword_init: true) do
    # diz se o periodo foi aceito
    # args: nenhum
    # retorna: true quando nao ha erro
    # efeito: nenhum
    def valido?
      erro.nil?
    end

    # soma o que as refeicoes liberadas custaram
    # args: nenhum
    # retorna: BigDecimal com a soma, zero sem refeicoes
    # efeito: nenhum
    def total_gasto
      refeicoes.sum { |acesso| acesso.valor_cobrado.to_d }
    end

    # soma as recargas aprovadas, so recarga aprovada entra no saldo
    # args: nenhum
    # retorna: BigDecimal com a soma, zero sem recargas aprovadas
    # efeito: nenhum
    def total_recarregado
      recargas.select(&:aprovada?).sum(&:valor)
    end
  end

  # prepara o extrato de um estudante
  # args: usuario (User), data_inicial e data_final (String dd/mm/aaaa), vazias valem sem limite
  # retorna: a instancia, com o periodo ja convertido
  # efeito: nenhum
  def initialize(usuario:, data_inicial: nil, data_final: nil)
    @usuario = usuario
    @periodo = PeriodoFiltro.new(data_inicial: data_inicial, data_final: data_final).call
  end

  # monta o extrato do estudante
  # args: nenhum
  # retorna: Resultado com recargas e refeicoes, ou vazio e com erro quando o periodo e invalido
  # efeito: so le o banco
  def call
    return Resultado.new(recargas: [], refeicoes: [], erro: @periodo.erro) unless @periodo.valido?

    Resultado.new(recargas: recargas, refeicoes: refeicoes)
  end

  private

  # todas as recargas do estudante no periodo, a data de cada uma e o created_at
  # args: nenhum
  # retorna: lista de Recarga, da mais recente para a mais antiga
  # efeito: so le o banco
  def recargas
    @periodo.aplicar(@usuario.recargas, :created_at).order(created_at: :desc, id: :desc).to_a
  end

  # refeicao e so acesso liberado ligado ao estudante
  # args: nenhum
  # retorna: lista de Access liberados no periodo, do mais recente para o mais antigo
  # efeito: so le o banco
  def refeicoes
    escopo = @usuario.accesses.where(resultado: 'LIBERADO').includes(:restaurant)
    @periodo.aplicar(escopo, :occurred_at).recent_first.order(id: :desc).to_a
  end
end
