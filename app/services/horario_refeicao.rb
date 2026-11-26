# frozen_string_literal: true

# Horários de funcionamento do RU (RN01 do Cardápio da Refeição Atual).
#
# Diz qual refeição está sendo servida agora e qual é a próxima. Os horários
# ficam no código, e não no banco. O início faz parte da refeição e o fim não.
class HorarioRefeicao
  # Uma refeição do RU: +chave+ (como no banco), +nome+ (como na tela) e os
  # horários de +inicio+ e +fim+ no formato "HH:MM".
  Refeicao = Data.define(:chave, :nome, :inicio, :fim)

  # As três refeições do dia, em ordem de horário.
  REFEICOES = [
    Refeicao.new(chave: 'cafe', nome: 'Café da manhã', inicio: '07:00', fim: '09:30'),
    Refeicao.new(chave: 'almoco', nome: 'Almoço', inicio: '11:00', fim: '14:30'),
    Refeicao.new(chave: 'jantar', nome: 'Jantar', inicio: '17:00', fim: '19:30')
  ].freeze

  # Descobre qual refeição está sendo servida em um horário.
  #
  # Argumentos::
  #   +agora+ - horário consultado (+Time+). Opcional; o padrão é a hora atual.
  # Retorno::
  #   A Refeicao em andamento, ou +nil+ se o RU estiver fora do horário de
  #   funcionamento.
  # Efeitos colaterais:: nenhum.
  def self.atual(agora = Time.current)
    hora = hora_de(agora)
    REFEICOES.find { |refeicao| hora >= refeicao.inicio && hora < refeicao.fim }
  end

  # Descobre a próxima refeição a partir de um horário (RN05).
  #
  # Argumentos::
  #   +agora+ - horário consultado (+Time+). Opcional; o padrão é a hora atual.
  # Retorno::
  #   A próxima Refeicao do dia. Depois do jantar, retorna o café da manhã
  #   (a primeira refeição do dia seguinte). Nunca retorna +nil+.
  # Efeitos colaterais:: nenhum.
  def self.proxima(agora = Time.current)
    hora = hora_de(agora)
    REFEICOES.find { |refeicao| refeicao.inicio > hora } || REFEICOES.first
  end

  # Procura uma refeição pelo nome exibido na tela.
  #
  # Argumentos::
  #   +nome+ - nome da refeição, por exemplo "Almoço". Maiúsculas e minúsculas
  #   não fazem diferença.
  # Retorno:: a Refeicao com esse nome, ou +nil+ se não existir.
  # Efeitos colaterais:: nenhum.
  def self.por_nome(nome)
    REFEICOES.find { |refeicao| refeicao.nome.casecmp?(nome) }
  end

  # Converte um horário para o texto "HH:MM" usado nas comparações.
  #
  # Argumentos::
  #   +agora+ - horário (+Time+).
  # Retorno:: +String+ no formato "HH:MM", por exemplo "12:05".
  # Efeitos colaterais:: nenhum.
  def self.hora_de(agora)
    agora.strftime('%H:%M')
  end
  private_class_method :hora_de
end
