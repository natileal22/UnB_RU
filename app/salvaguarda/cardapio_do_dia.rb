# frozen_string_literal: true

# cardapio do dia e da semana vindo da api e, se ela falhar, da reserva no banco (Cardapio e ItemCardapio)
class CardapioDoDia
  DIAS = %w[Domingo Segunda-feira Terça-feira Quarta-feira Quinta-feira Sexta-feira Sábado].freeze
  CHAVE_CACHE = 'cardapio_api/semana_vigente'
  ERROS_DE_REDE = [SocketError, SystemCallError, Timeout::Error, OpenSSL::SSL::SSLError].freeze
  # nome na tela e campos da api onde o texto pode estar
  EXTRAS = {
    'Guarnições' => %w[acompanhamentos], 'Salada' => %w[molho_para_salada],
    'Bebida' => %w[bebida_refresco bebidas], 'Pães' => %w[panificacao]
  }.freeze

  # opcoes sao pares de tipo e prato e extras e um hash de nome e texto
  Refeicao = Struct.new(:horario, :opcoes, :extras)

  # as refeicoes do dia na ordem de HorarioRefeicao, cafe almoco e jantar
  def dia(data)
    bloco_do_dia = dias_da_api[data.iso8601]
    HorarioRefeicao::REFEICOES.map do |horario|
      next da_reserva(horario, data) unless bloco_do_dia

      da_api(horario, bloco_do_dia.dig('refeicoes', CardapioApi::Cliente::MAPA_REFEICOES[horario.chave]))
    end
  end

  # os 7 dias da semana da api ou, sem ela, a semana de hoje de segunda a domingo
  def semana
    datas = dias_da_api.keys.map { |texto| Date.iso8601(texto) }
    datas = (Time.zone.today.beginning_of_week..Time.zone.today.end_of_week).to_a if datas.empty?
    datas.sort.map { |data| [data, dia(data)] }
  end

  def fonte
    dias_da_api.empty? ? :reserva : :api
  end

  private

  def dias_da_api
    @dias_da_api ||= Array(semana_da_api&.fetch('dias', nil)).index_by { |dia| dia['data'] }
  end

  # a api e lenta entao a semana fica guardada por um tempo e erro nao entra no cache
  def semana_da_api
    Rails.cache.fetch(CHAVE_CACHE, expires_in: 10.minutes) { CardapioApi::Cliente.semana_vigente }
  rescue CardapioApi::ErroApi, *ERROS_DE_REDE
    nil
  end

  def da_api(horario, bloco)
    return Refeicao.new(horario, [], {}) unless bloco.is_a?(Hash)

    campos = horario.chave == 'cafe' ? CardapioApi::Cliente::CAMPOS_CAFE : CardapioApi::Cliente::CAMPOS_PRINCIPAIS
    opcoes = campos.filter_map do |tipo, campo|
      [ItemCardapio::TIPOS.fetch(tipo), texto(bloco[campo])] if bloco[campo].present?
    end
    Refeicao.new(horario, opcoes, extras(bloco))
  end

  def extras(bloco)
    EXTRAS.filter_map do |nome, campos|
      valor = bloco.values_at(*campos).find(&:present?)
      [nome, texto(valor)] if valor
    end.to_h
  end

  # a api manda lista ou texto
  def texto(valor)
    valor.is_a?(Array) ? valor.join(', ') : valor.to_s
  end

  def da_reserva(horario, data)
    cardapio = Cardapio.includes(:itens).find_by(data: data, refeicao: horario.chave)
    opcoes = cardapio ? cardapio.itens_ordenados.map { |item| [item.nome_do_tipo, item.item] } : []
    Refeicao.new(horario, opcoes, {})
  end
end
