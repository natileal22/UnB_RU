# frozen_string_literal: true

# cardapio completo do dia e da semana, pagina publica e a da Natalia em /cardapio segue como esta
class CardapioCompletoController < ApplicationController
  # mostra cafe, almoco e jantar de hoje com a refeicao em servico marcada
  # args: nenhum
  # retorna: renderiza hoje com as refeicoes, de onde vieram os dados, a refeicao atual e a hora
  # efeito: pode chamar a api do cardapio, nao grava nada
  def hoje
    servico = CardapioDoDia.new
    @refeicoes = servico.dia(Time.zone.today)
    @fonte = servico.fonte
    @atual = HorarioRefeicao.atual
    @hora = Time.current.strftime('%H:%M')
  end

  # mostra os 7 dias da semana com o dia de hoje em destaque
  # args: nenhum
  # retorna: renderiza semana com os dias, de onde vieram os dados e a data de hoje
  # efeito: pode chamar a api do cardapio, nao grava nada
  def semana
    servico = CardapioDoDia.new
    @dias = servico.semana
    @fonte = servico.fonte
    @hoje = Time.zone.today
  end
end
