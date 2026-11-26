# frozen_string_literal: true

# cardapio do dia e da semana vindo da api e, se ela falhar, da reserva no banco (Cardapio e ItemCardapio)
class CardapioDoDia
  DIAS = %w[Domingo Segunda-feira Terça-feira Quarta-feira Quinta-feira Sexta-feira Sábado].freeze
  CHAVE_CACHE = 'cardapio_api/semana_vigente'
  # nome na tela e campos da api onde o texto pode estar
  EXTRAS = {
    'Guarnições' => %w[acompanhamentos], 'Salada' => %w[molho_para_salada],
    'Bebida' => %w[bebida_refresco bebidas], 'Pães' => %w[panificacao]
  }.freeze

  # opcoes sao pares de tipo e prato e extras e um hash de nome e texto
  Refeicao = Struct.new(:horario, :opcoes, :extras)

  # monta as refeicoes de um dia na ordem do HorarioRefeicao, cafe almoco e jantar
  # args: data (Date) do dia pedido
  # retorna: lista de Refeicao, da api quando ela tem o dia e da reserva no banco quando nao tem
  # efeito: pode chamar a api e guardar a semana no cache, nao grava no banco
  def dia(data)
    bloco_do_dia = dias_da_api[data]
    HorarioRefeicao::REFEICOES.map do |horario|
      next da_reserva(horario, data) unless bloco_do_dia

      da_api(horario, bloco_do_dia.dig('refeicoes', CardapioApi::Cliente::MAPA_REFEICOES[horario.chave]))
    end
  end

  # monta os 7 dias da semana
  # args: nenhum
  # retorna: lista de pares data e refeicoes do dia, os dias da api ou, sem ela, a semana de hoje de segunda a domingo
  # efeito: igual ao dia, pode chamar a api e usar o cache
  def semana
    datas = dias_da_api.keys.presence || Time.zone.today.all_week
    datas.sort.map { |data| [data, dia(data)] }
  end

  # diz de onde vieram os dados
  # args: nenhum
  # retorna: :api quando a api respondeu e :reserva quando ela falhou
  # efeito: pode chamar a api na primeira vez
  def fonte
    dias_da_api.empty? ? :reserva : :api
  end

  # le uma refeicao do banco, usada como reserva e na home do estudante
  # args: horario (HorarioRefeicao::Refeicao) da refeicao e data (Date) do dia
  # retorna: Refeicao com as opcoes cadastradas, ou sem opcoes quando o dia nao tem cardapio
  # efeito: so le o banco
  def da_reserva(horario, data)
    cardapio = Cardapio.includes(:itens).find_by(data: data, refeicao: horario.chave)
    opcoes = cardapio ? cardapio.itens_ordenados.map { |item| [item.nome_do_tipo, item.item] } : []
    Refeicao.new(horario, opcoes, {})
  end

  private

  # indexa os dias da api pela data para achar o dia pedido sem percorrer a lista
  # args: nenhum
  # retorna: hash de Date para o dia da api, vazio quando a api falhou
  # efeito: chama a api uma vez e guarda o resultado na instancia
  def dias_da_api
    @dias_da_api ||= Array(semana_da_api&.fetch('dias', nil)).index_by { |dia| Date.iso8601(dia['data']) }
  end

  # a api e lenta entao a semana fica guardada por um tempo e erro nao entra no cache
  # args: nenhum
  # retorna: o hash da semana ou nil quando o cliente lancou ErroApi
  # efeito: le e grava o cache do Rails por 10 minutos
  def semana_da_api
    Rails.cache.fetch(CHAVE_CACHE, expires_in: 10.minutes) { CardapioApi::Cliente.semana_vigente }
  rescue CardapioApi::ErroApi
    nil
  end

  # converte o bloco de uma refeicao da api para opcoes e extras
  # args: horario (HorarioRefeicao::Refeicao) e bloco (Hash da api ou nil quando a refeicao nao veio)
  # retorna: Refeicao, sem opcoes nem extras quando a refeicao nao veio
  # efeito: nenhum
  def da_api(horario, bloco)
    bloco ||= {}
    opcoes = CardapioApi::Cliente::CAMPOS.fetch(horario.chave).filter_map do |tipo, campo|
      [ItemCardapio::TIPOS.fetch(tipo), texto(bloco[campo])] if bloco[campo].present?
    end
    Refeicao.new(horario, opcoes, extras(bloco))
  end

  # guarnicoes, salada, bebida e paes que a api traz alem dos pratos
  # args: bloco (Hash) da refeicao
  # retorna: hash de nome na tela para texto, so com o que veio preenchido
  # efeito: nenhum
  def extras(bloco)
    EXTRAS.filter_map do |nome, campos|
      valor = bloco.values_at(*campos).find(&:present?)
      [nome, texto(valor)] if valor
    end.to_h
  end

  # a api manda lista ou texto
  # args: valor (Array ou String)
  # retorna: texto, com os itens da lista separados por virgula
  # efeito: nenhum
  def texto(valor)
    valor.is_a?(Array) ? valor.join(', ') : valor.to_s
  end
end
