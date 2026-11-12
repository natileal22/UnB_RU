class CatracasController < ApplicationController
  before_action :carregar_catraca

  def show
  end

  def entrada
    @resultado = ValidacaoEntrada.new(
      catraca: @catraca,
      matricula: params[:matricula],
      restaurante_selecionado_id: session[:restaurant_id]
    ).call

    render :show, status: (@resultado.liberado? ? :ok : :unprocessable_entity)
  end

  private

  def carregar_catraca
    @catraca = Catraca.find(params[:id])
  end
end
