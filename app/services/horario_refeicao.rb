# Horários de funcionamento do RU. Diz qual refeição está sendo servida agora e qual é a próxima.
class HorarioRefeicao
  Refeicao = Data.define(:chave, :nome, :inicio, :fim)

  REFEICOES = [
    Refeicao.new(chave: 'cafe', nome: 'Café da manhã', inicio: '07:00', fim: '09:30'),
    Refeicao.new(chave: 'almoco', nome: 'Almoço', inicio: '11:00', fim: '14:30'),
    Refeicao.new(chave: 'jantar', nome: 'Jantar', inicio: '17:00', fim: '19:30')
  ].freeze

  def self.atual(agora = Time.current)
    hora = agora.strftime('%H:%M')
    REFEICOES.find { |refeicao| hora >= refeicao.inicio && hora < refeicao.fim }
  end

  # Fora do horário, a próxima refeição do dia; depois do jantar, volta para o café da manhã.
  def self.proxima(agora = Time.current)
    hora = agora.strftime('%H:%M')
    REFEICOES.find { |refeicao| refeicao.inicio > hora } || REFEICOES.first
  end

  def self.por_nome(nome)
    REFEICOES.find { |refeicao| refeicao.nome.casecmp?(nome) }
  end
end