# frozen_string_literal: true

# historico local da catraca da issue 7 com filtro por data
class HistoricoLocal
  FORMATO_DATA = %r{\A\d{2}/\d{2}/\d{4}\z}
  MSG_DATA_INVALIDA = 'Data inválida: use o formato dd/mm/aaaa'
  MSG_PERIODO_INVERTIDO = 'A data inicial não pode ser posterior à data final'

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
    @data_inicial = data_inicial.to_s.strip
    @data_final = data_final.to_s.strip
  end

  def call
    catracas = Catraca.vinculadas_a(@usuario).includes(:restaurant).order(:restaurant_id, :codigo).to_a
    inicio = converter(@data_inicial)
    fim = converter(@data_final)
    erro = validar(inicio, fim)
    return Resultado.new(acessos: [], catracas: catracas, erro: erro) if erro

    Resultado.new(acessos: buscar(catracas, inicio, fim), catracas: catracas)
  end

  private

  # invalida quando nao e data real e nil quando vazio
  def converter(texto)
    return nil if texto.empty?
    return :invalida unless texto.match?(FORMATO_DATA)

    Date.strptime(texto, '%d/%m/%Y')
  rescue Date::Error
    :invalida
  end

  def validar(inicio, fim)
    return MSG_DATA_INVALIDA if inicio == :invalida || fim == :invalida

    MSG_PERIODO_INVERTIDO if inicio && fim && inicio > fim
  end

  def buscar(catracas, inicio, fim)
    return [] if catracas.empty?

    escopo = catracas.map { |c| Access.where(restaurant_id: c.restaurant_id, catraca: c.codigo) }.reduce(:or)
    escopo = escopo.where(occurred_at: inicio.beginning_of_day..) if inicio
    escopo = escopo.where(occurred_at: ..fim.end_of_day) if fim
    escopo.includes(:restaurant).recent_first.to_a
  end
end
