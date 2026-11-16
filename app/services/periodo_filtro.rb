# frozen_string_literal: true

# conversor unico de periodo dd/mm/aaaa das issues 3 7 e 12 e vazio significa sem limite
# com obrigatorio vazio conta como data invalida
class PeriodoFiltro
  FORMATO_DATA = %r{\A\d{2}/\d{2}/\d{4}\z}
  MSG_DATA_INVALIDA = 'Data inválida: use o formato dd/mm/aaaa'
  MSG_PERIODO_INVERTIDO = 'A data inicial não pode ser posterior à data final'

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

  def initialize(data_inicial: nil, data_final: nil, obrigatorio: false)
    @obrigatorio = obrigatorio
    @data_inicial = data_inicial.to_s.strip
    @data_final = data_final.to_s.strip
  end

  def call
    inicio = converter(@data_inicial)
    fim = converter(@data_final)
    return Resultado.new(erro: MSG_DATA_INVALIDA) if inicio == :invalida || fim == :invalida
    return Resultado.new(erro: MSG_PERIODO_INVERTIDO) if inicio && fim && inicio > fim

    Resultado.new(inicio: inicio, fim: fim)
  end

  private

  # nil quando vazio e invalida quando nao e data real
  def converter(texto)
    return nil if texto.empty? && !@obrigatorio
    return :invalida unless texto.match?(FORMATO_DATA)

    Date.strptime(texto, '%d/%m/%Y')
  rescue Date::Error
    :invalida
  end
end
