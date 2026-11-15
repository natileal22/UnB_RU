# frozen_string_literal: true

# cardapio completo do dia e da semana, pagina publica e a da Natalia em /cardapio segue como esta
class CardapioCompletoController < ApplicationController
  def hoje
    servico = CardapioDoDia.new
    @refeicoes = servico.dia(Time.zone.today)
    @fonte = servico.fonte
    @atual = HorarioRefeicao.atual
    @hora = Time.current.strftime('%H:%M')
  end

  def semana
    servico = CardapioDoDia.new
    @dias = servico.semana
    @fonte = servico.fonte
    @hoje = Time.zone.today
  end
end
