# frozen_string_literal: true

# exportacao em pdf do relatorio global da issue 12 com periodo obrigatorio e filtros opcionais
class ExportacaoRelatorio
  MSG_SEM_REGISTROS = 'Não há registros no período para exportar'
  MSG_FILTRO_SEM_REGISTROS = 'Nenhum registro encontrado para os filtros informados'
  MSG_FALHA = 'Não foi possível gerar o PDF. Tente novamente'

  Resultado = Struct.new(:pdf, :arquivo, :erro, :status, keyword_init: true) do
    def sucesso?
      erro.nil?
    end
  end

  def initialize(data_inicial: nil, data_final: nil, restaurant_id: nil, catraca: nil)
    @periodo = PeriodoFiltro.new(data_inicial: data_inicial, data_final: data_final, obrigatorio: true).call
    @restaurant_id = restaurant_id.to_s.strip
    @catraca = catraca.to_s.strip
  end

  def call
    return recusar(@periodo.erro) unless @periodo.valido?

    inicio = @periodo.inicio
    fim = @periodo.fim
    acessos = buscar(inicio, fim)
    return recusar(motivo_sem_registros(inicio, fim)) if acessos.empty?

    gerar(inicio, fim, acessos)
  end

  private

  # mesmos filtros de restaurante e catraca do relatorio global
  def buscar(inicio, fim)
    acessos = Access.includes(:restaurant).recent_first.where(occurred_at: periodo(inicio, fim))
    acessos = acessos.where(restaurant_id: @restaurant_id) if @restaurant_id.present?
    acessos = acessos.where(catraca: @catraca) if @catraca.present?
    acessos.to_a
  end

  def periodo(inicio, fim)
    inicio.beginning_of_day..fim.end_of_day
  end

  # mensagem propria so quando o periodo tem registros e o filtro de restaurante ou catraca nao achou nenhum
  def motivo_sem_registros(inicio, fim)
    filtrado = @restaurant_id.present? || @catraca.present?
    return MSG_SEM_REGISTROS unless filtrado && Access.exists?(occurred_at: periodo(inicio, fim))

    MSG_FILTRO_SEM_REGISTROS
  end

  def gerar(inicio, fim, acessos)
    linhas = cabecalho(inicio, fim, acessos) + acessos.map { |acesso| linha(acesso) }
    Resultado.new(pdf: GeradorPdf.gerar(linhas: linhas), arquivo: nome_do_arquivo(inicio, fim))
  rescue StandardError => e
    Rails.logger.error("falha ao gerar o pdf do relatorio: #{e.class} #{e.message}")
    Resultado.new(erro: MSG_FALHA, status: :internal_server_error)
  end

  # a catraca entra no nome so quando filtrada e sem caractere que nao seja letra numero hifen ou sublinhado
  def nome_do_arquivo(inicio, fim)
    catraca = @catraca.gsub(/[^A-Za-z0-9_-]/, '_')[0, 30].presence
    "#{['relatorio_operacao', catraca, "#{inicio.iso8601}_a_#{fim.iso8601}"].compact.join('_')}.pdf"
  end

  def cabecalho(inicio, fim, acessos)
    liberados = acessos.count { |acesso| acesso.resultado == 'LIBERADO' }
    ['Relatório Global de Operação',
     "Período: #{inicio.strftime('%d/%m/%Y')} a #{fim.strftime('%d/%m/%Y')}",
     *filtros_aplicados(acessos),
     "Total de acessos: #{acessos.size} | Liberados: #{liberados} | Negados: #{acessos.size - liberados}",
     '',
     'Data e hora | Restaurante | Catraca | Matrícula | Resultado']
  end

  def filtros_aplicados(acessos)
    [(@restaurant_id.present? ? "Restaurante: #{acessos.first.restaurant.name}" : nil),
     (@catraca.present? ? "Catraca: #{@catraca}" : nil)].compact
  end

  def linha(acesso)
    [I18n.l(acesso.occurred_at, format: '%d/%m/%Y %H:%M'), acesso.restaurant.name, acesso.catraca,
     acesso.matricula, acesso.resultado].join(' | ')
  end

  def recusar(erro)
    Resultado.new(erro: erro, status: :unprocessable_content)
  end
end
