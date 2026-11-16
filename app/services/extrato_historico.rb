# frozen_string_literal: true

# extrato de recargas e historico de refeicoes do proprio estudante da issue 3
class ExtratoHistorico
  Resultado = Struct.new(:recargas, :refeicoes, :erro, keyword_init: true) do
    def valido?
      erro.nil?
    end

    def total_gasto
      refeicoes.sum { |acesso| acesso.valor_cobrado.to_d }
    end

    # so recarga aprovada entra no saldo
    def total_recarregado
      recargas.select(&:aprovada?).sum(&:valor)
    end
  end

  def initialize(usuario:, data_inicial: nil, data_final: nil)
    @usuario = usuario
    @periodo = PeriodoFiltro.new(data_inicial: data_inicial, data_final: data_final).call
  end

  def call
    return Resultado.new(recargas: [], refeicoes: [], erro: @periodo.erro) unless @periodo.valido?

    Resultado.new(recargas: recargas, refeicoes: refeicoes)
  end

  private

  # todas as recargas e a data de cada uma e o created_at
  def recargas
    @periodo.aplicar(@usuario.recargas, :created_at).order(created_at: :desc, id: :desc).to_a
  end

  # refeicao e so acesso liberado ligado ao usuario
  def refeicoes
    escopo = @usuario.accesses.where(resultado: 'LIBERADO').includes(:restaurant)
    @periodo.aplicar(escopo, :occurred_at).recent_first.order(id: :desc).to_a
  end
end
