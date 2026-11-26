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

  # uma refeicao do dia com as opcoes e os extras, que se monta sozinha a partir da api ou do banco
  # opcoes sao pares de tipo e prato e extras e um hash de nome e texto
  Refeicao = Struct.new(:horario, :opcoes, :extras) do
    # le uma refeicao do banco, usada como reserva e na home do estudante
    # args: horario (HorarioRefeicao::Refeicao) da refeicao e data (Date) do dia
    # retorna: Refeicao com as opcoes cadastradas, ou sem opcoes quando o dia nao tem cardapio
    # efeito: so le o banco
    def self.da_reserva(horario, data)
      cardapio = Cardapio.includes(:itens).find_by(data: data, refeicao: horario.chave)
      opcoes = cardapio ? cardapio.itens_ordenados.map { |item| [item.nome_do_tipo, item.item] } : []
      new(horario, opcoes, {})
    end

    # converte uma refeicao do dia da api para opcoes e extras
    # args: horario (HorarioRefeicao::Refeicao) e dia (Hash) do dia da api, com os blocos de cada refeicao
    # retorna: Refeicao, sem opcoes nem extras quando a refeicao nao veio no dia
    # efeito: nenhum
    def self.da_api(horario, dia)
      refeicao = CardapioApi::Cliente::REFEICOES.fetch(horario.chave)
      bloco = dia.dig('refeicoes', refeicao[:chave]) || {}
      new(horario, opcoes(refeicao[:campos], bloco), extras(bloco))
    end

    # um par de tipo e prato para cada campo da refeicao que a api trouxe preenchido
    # args: campos (Hash) de tipo de opcao para o campo da api e bloco (Hash) da refeicao
    # retorna: lista de pares, com o prato em texto mesmo quando a api manda lista
    # efeito: nenhum
    def self.opcoes(campos, bloco)
      campos.filter_map do |tipo, campo|
        valor = bloco[campo]
        [ItemCardapio::TIPOS.fetch(tipo), Array(valor).join(', ')] if valor.present?
      end
    end

    # guarnicoes, salada, bebida e paes que a api traz alem dos pratos, em lista ou em texto
    # args: bloco (Hash) da refeicao
    # retorna: hash de nome na tela para texto, so com o que veio preenchido
    # efeito: nenhum
    def self.extras(bloco)
      EXTRAS.filter_map do |nome, campos|
        valor = bloco.values_at(*campos).find(&:present?)
        [nome, Array(valor).join(', ')] if valor
      end.to_h
    end
    private_class_method :opcoes, :extras
  end

  # monta as refeicoes de um dia na ordem do HorarioRefeicao, cafe almoco e jantar
  # args: data (Date) do dia pedido
  # retorna: lista de Refeicao, da api quando ela tem o dia e da reserva no banco quando nao tem
  # efeito: pode chamar a api e guardar a semana no cache, nao grava no banco
  def dia(data)
    dia_da_api = dias_da_api[data]
    HorarioRefeicao::REFEICOES.map do |horario|
      dia_da_api ? Refeicao.da_api(horario, dia_da_api) : Refeicao.da_reserva(horario, data)
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

  private

  # os dias da api indexados pela data, para achar o dia pedido sem percorrer a lista
  # a api e lenta entao a semana fica guardada por um tempo e erro nao entra no cache
  # args: nenhum
  # retorna: hash de Date para o dia da api, vazio quando o cliente lancou ErroApi
  # efeito: chama a api uma vez, guarda o resultado na instancia e usa o cache do Rails por 10 minutos
  def dias_da_api
    @dias_da_api ||= begin
      semana = Rails.cache.fetch(CHAVE_CACHE, expires_in: 10.minutes) { CardapioApi::Cliente.semana_vigente }
      Array(semana['dias']).index_by { |dia| Date.iso8601(dia['data']) }
    rescue CardapioApi::ErroApi
      {}
    end
  end
end
