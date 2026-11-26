# frozen_string_literal: true

# historico local da catraca da issue 7 com filtro por data
class HistoricoLocal
  Resultado = Struct.new(:acessos, :catracas, :erro, :passagens, :arrecadacao, keyword_init: true) do
    # diz se o periodo foi aceito
    # args: nenhum
    # retorna: true quando nao ha erro
    # efeito: nenhum
    def valido?
      erro.nil?
    end

    # mensagem de erro do periodo
    # args: nenhum
    # retorna: String ou nil quando nao ha erro
    # efeito: nenhum
    def mensagem
      erro
    end

    # diz se o funcionario nao tem catraca vinculada
    # args: nenhum
    # retorna: true quando a lista de catracas esta vazia
    # efeito: nenhum
    def sem_catraca?
      catracas.empty?
    end
  end

  # prepara o historico de um funcionario
  # args: usuario (User), data_inicial e data_final (String dd/mm/aaaa) e resultado (String)
  #       status desconhecido vale como todos
  # retorna: a instancia, com o periodo ja convertido
  # efeito: nenhum
  def initialize(usuario:, data_inicial: nil, data_final: nil, resultado: nil)
    @usuario = usuario
    # status que nao existe vale como todos
    @status = resultado if Access::RESULTS.include?(resultado)
    @periodo = PeriodoFiltro.new(data_inicial: data_inicial, data_final: data_final).call
  end

  # monta o historico das catracas vinculadas ao funcionario
  # args: nenhum
  # retorna: Resultado com acessos, catracas, passagens e arrecadacao, ou com erro e zeros se o periodo for invalido
  # efeito: so le o banco
  def call
    catracas = Catraca.vinculadas_a(@usuario).includes(:restaurant).order(:restaurant_id, :codigo).to_a
    return recusar(catracas) unless @periodo.valido?

    periodo = acessos_do_periodo(catracas)
    liberados = periodo.where(resultado: 'LIBERADO')
    Resultado.new(acessos: listar(periodo), catracas: catracas,
                  passagens: liberados.count, arrecadacao: liberados.sum(:valor_cobrado))
  end

  private

  # resultado de periodo invalido, sem acessos
  # args: catracas (Array de Catraca)
  # retorna: Resultado com erro, lista vazia e totais zerados
  # efeito: nenhum
  def recusar(catracas)
    Resultado.new(acessos: [], catracas: catracas, erro: @periodo.erro, passagens: 0, arrecadacao: 0)
  end

  # os cartoes usam o periodo todo e so a lista respeita o filtro de status
  # args: catracas (Array de Catraca) do funcionario
  # retorna: relacao de Access do periodo, vazia quando nao ha catraca
  # efeito: so le o banco
  def acessos_do_periodo(catracas)
    return Access.none if catracas.empty?

    escopo = catracas.map { |c| Access.where(restaurant_id: c.restaurant_id, catraca: c.codigo) }.reduce(:or)
    @periodo.aplicar(escopo, :occurred_at)
  end

  # aplica o filtro de status e carrega o restaurante de cada acesso
  # args: periodo (relacao de Access)
  # retorna: lista de Access, do mais recente para o mais antigo
  # efeito: so le o banco
  def listar(periodo)
    periodo = periodo.where(resultado: @status) if @status
    periodo.includes(:restaurant).recent_first.to_a
  end
end
