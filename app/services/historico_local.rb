# frozen_string_literal: true

# historico local da catraca da issue 7 com filtro por data
class HistoricoLocal
  Resultado = Struct.new(:acessos, :catracas, :erro, :passagens, :arrecadacao, keyword_init: true) do
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

  def initialize(usuario:, data_inicial: nil, data_final: nil, resultado: nil)
    @usuario = usuario
    # status que nao existe vale como todos
    @status = resultado if Access::RESULTS.include?(resultado)
    @periodo = PeriodoFiltro.new(data_inicial: data_inicial, data_final: data_final).call
  end

  def call
    catracas = Catraca.vinculadas_a(@usuario).includes(:restaurant).order(:restaurant_id, :codigo).to_a
    return recusar(catracas) unless @periodo.valido?

    periodo = acessos_do_periodo(catracas)
    liberados = periodo.where(resultado: 'LIBERADO')
    Resultado.new(acessos: listar(periodo), catracas: catracas,
                  passagens: liberados.count, arrecadacao: liberados.sum(:valor_cobrado))
  end

  private

  def recusar(catracas)
    Resultado.new(acessos: [], catracas: catracas, erro: @periodo.erro, passagens: 0, arrecadacao: 0)
  end

  # os cartoes usam o periodo todo e so a lista respeita o filtro de status
  def acessos_do_periodo(catracas)
    return Access.none if catracas.empty?

    escopo = catracas.map { |c| Access.where(restaurant_id: c.restaurant_id, catraca: c.codigo) }.reduce(:or)
    @periodo.aplicar(escopo, :occurred_at)
  end

  def listar(periodo)
    periodo = periodo.where(resultado: @status) if @status
    periodo.includes(:restaurant).recent_first.to_a
  end
end
