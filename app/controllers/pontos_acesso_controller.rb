class PontosAcessoController < ApplicationController
  before_action :exigir_login
  before_action :exigir_perfil_operador

  def new
    @restaurantes = Restaurant.ativos.order(:name)
  end

  def create
    return recusar("Selecione um restaurante para continuar") if params[:restaurant_id].blank?

    restaurante = restaurante_operacional(params[:restaurant_id])
    return recusar("Restaurante indisponível para operação") unless restaurante

    session[:restaurant_id] = restaurante.id
    redirect_to operacao_path, notice: "Ponto de acesso configurado"
  end

  private

  def restaurante_operacional(id)
    r = Restaurant.find_by(id: id)
    r if r&.ativo?
  end

  def recusar(mensagem)
    @restaurantes = Restaurant.ativos.order(:name)
    flash.now[:alert] = mensagem
    render :new, status: :unprocessable_entity
  end
end
