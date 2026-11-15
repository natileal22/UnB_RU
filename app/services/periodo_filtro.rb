# frozen_string_literal: true

# periodo opcional dd/mm/aaaa da issue 3 e vazio significa sem limite
class PeriodoFiltro
  Resultado = Struct.new(:inicio, :fim, :erro, keyword_init: true) do
    def valido?
      erro.nil?
    end

    # restringe o escopo ao periodo incluindo os dois dias limites
    def aplicar(escopo, coluna)
      escopo = escopo.where(coluna => inicio.beginning_of_day..) if inicio
      escopo = escopo.where(coluna => ..fim.end_of_day) if fim
      escopo
    end
  end

  def initialize(data_inicial: nil, data_final: nil)
    @data_inicial = data_inicial.to_s.strip
    @data_final = data_final.to_s.strip
  end

  def call
    inicio = converter(@data_inicial)
    fim = converter(@data_final)
    return Resultado.new(erro: HistoricoLocal::MSG_DATA_INVALIDA) if inicio == :invalida || fim == :invalida
    return Resultado.new(erro: HistoricoLocal::MSG_PERIODO_INVERTIDO) if inicio && fim && inicio > fim

    Resultado.new(inicio: inicio, fim: fim)
  end

  private

  # nil quando vazio e invalida quando nao e data real
  def converter(texto)
    return nil if texto.empty?
    return :invalida unless texto.match?(HistoricoLocal::FORMATO_DATA)

    Date.strptime(texto, '%d/%m/%Y')
  rescue Date::Error
    :invalida
  end
end
