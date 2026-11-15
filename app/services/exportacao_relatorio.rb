# frozen_string_literal: true

# exportacao em pdf do relatorio global da issue 12 com periodo obrigatorio e filtros opcionais
class ExportacaoRelatorio
  MSG_SEM_REGISTROS = 'Não há registros no período para exportar'
  MSG_FALHA = 'Não foi possível gerar o PDF. Tente novamente'

  Resultado = Struct.new(:pdf, :arquivo, :erro, :status, keyword_init: true) do
    def sucesso?
      erro.nil?
    end
  end

  def initialize(data_inicial: nil, data_final: nil, restaurant_id: nil, catraca: nil)
    @data_inicial = data_inicial.to_s.strip
    @data_final = data_final.to_s.strip
    @restaurant_id = restaurant_id.to_s.strip
    @catraca = catraca.to_s.strip
  end

  def call
    inicio = converter(@data_inicial)
    fim = converter(@data_final)
    erro = validar(inicio, fim)
    return recusar(erro) if erro

    acessos = buscar(inicio, fim)
    return recusar(MSG_SEM_REGISTROS) if acessos.empty?

    gerar(inicio, fim, acessos)
  end

  private

  # invalida marca texto que nao e data real e vazio tambem conta como invalido
  def converter(texto)
    return :invalida unless texto.match?(HistoricoLocal::FORMATO_DATA)

    Date.strptime(texto, '%d/%m/%Y')
  rescue Date::Error
    :invalida
  end

  def validar(inicio, fim)
    return HistoricoLocal::MSG_DATA_INVALIDA if inicio == :invalida || fim == :invalida

    HistoricoLocal::MSG_PERIODO_INVERTIDO if inicio > fim
  end

  # mesmos filtros de restaurante e catraca do relatorio global
  def buscar(inicio, fim)
    acessos = Access.includes(:restaurant).recent_first.where(occurred_at: inicio.beginning_of_day..fim.end_of_day)
    acessos = acessos.where(restaurant_id: @restaurant_id) if @restaurant_id.present?
    acessos = acessos.where(catraca: @catraca) if @catraca.present?
    acessos.to_a
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
