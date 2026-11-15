# frozen_string_literal: true

# historico local da catraca da issue 7 com filtro por data
class HistoricoLocal
  Resultado = Struct.new(:acessos, :catracas, :erro, keyword_init: true) do
    def valido?
      erro.nil?
    end

    def mensagem
      erro
    end

    def sem_catraca?
      catracas.empty?
    end
  end

  def initialize(usuario:, data_inicial: nil, data_final: nil)
    @usuario = usuario
    @periodo = PeriodoFiltro.new(data_inicial: data_inicial, data_final: data_final).call
  end

  def call
    catracas = Catraca.vinculadas_a(@usuario).includes(:restaurant).order(:restaurant_id, :codigo).to_a
    return Resultado.new(acessos: [], catracas: catracas, erro: @periodo.erro) unless @periodo.valido?

    Resultado.new(acessos: buscar(catracas), catracas: catracas)
  end

  private

  def buscar(catracas)
    return [] if catracas.empty?

    escopo = catracas.map { |c| Access.where(restaurant_id: c.restaurant_id, catraca: c.codigo) }.reduce(:or)
    @periodo.aplicar(escopo, :occurred_at).includes(:restaurant).recent_first.to_a
  end
end
