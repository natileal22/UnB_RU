# frozen_string_literal: true

# conversor unico de periodo dd/mm/aaaa das issues 3 7 e 12 e vazio significa sem limite
# com obrigatorio vazio conta como data invalida
class PeriodoFiltro
  FORMATO_DATA = %r{\A\d{2}/\d{2}/\d{4}\z}
  MSG_DATA_INVALIDA = 'Data inválida: use o formato dd/mm/aaaa'
  MSG_PERIODO_INVERTIDO = 'A data inicial não pode ser posterior à data final'

  Resultado = Struct.new(:inicio, :fim, :erro, keyword_init: true) do
    # diz se o periodo foi aceito
    # args: nenhum
    # retorna: true quando nao ha erro
    # efeito: nenhum
    def valido?
      erro.nil?
    end

    # restringe o escopo ao periodo incluindo os dois dias limites
    # args: escopo (relacao do ActiveRecord) e coluna (Symbol) de data
    # retorna: o escopo filtrado, e sem o limite que ficou vazio
    # efeito: nenhum
    def aplicar(escopo, coluna)
      escopo = escopo.where(coluna => inicio.beginning_of_day..) if inicio
      escopo = escopo.where(coluna => ..fim.end_of_day) if fim
      escopo
    end
  end

  # prepara o periodo a partir dos textos do filtro
  # args: data_inicial e data_final (String dd/mm/aaaa) e obrigatorio (Boolean), vazio vale sem limite quando
  #       nao e obrigatorio
  # retorna: a instancia
  # efeito: nenhum
  def initialize(data_inicial: nil, data_final: nil, obrigatorio: false)
    @obrigatorio = obrigatorio
    @data_inicial = data_inicial.to_s.strip
    @data_final = data_final.to_s.strip
  end

  # converte e valida o periodo
  # args: nenhum
  # retorna: Resultado com inicio e fim (Date ou nil), ou com erro de data invalida ou periodo invertido
  # efeito: nenhum
  def call
    inicio = converter(@data_inicial)
    fim = converter(@data_final)
    return Resultado.new(erro: MSG_DATA_INVALIDA) if inicio == :invalida || fim == :invalida
    return Resultado.new(erro: MSG_PERIODO_INVERTIDO) if inicio && fim && inicio > fim

    Resultado.new(inicio: inicio, fim: fim)
  end

  private

  # converte um texto dd/mm/aaaa em data
  # args: texto (String)
  # retorna: Date, nil quando vazio e nao obrigatorio, ou :invalida quando nao e data real
  # efeito: nenhum
  def converter(texto)
    return nil if texto.empty? && !@obrigatorio
    return :invalida unless texto.match?(FORMATO_DATA)

    Date.strptime(texto, '%d/%m/%Y')
  rescue Date::Error
    :invalida
  end
end
