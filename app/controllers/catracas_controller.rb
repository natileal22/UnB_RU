class CatracasController < ApplicationController
  layout "operador"
  before_action :carregar_catraca
  before_action :carregar_ultimas_validacoes

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

  def carregar_ultimas_validacoes
    @ultimas_validacoes = @catraca.acessos.recent_first.limit(10)
  end
end
