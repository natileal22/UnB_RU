class CardapiosController < ApplicationController
  def show
    @refeicao = HorarioRefeicao.atual
    if @refeicao
      @cardapio = Cardapio.includes(:itens).find_by(data: Time.zone.today, refeicao: @refeicao.chave)
    else
      @proxima = HorarioRefeicao.proxima
    end
  end
end