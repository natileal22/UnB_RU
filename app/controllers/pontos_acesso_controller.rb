class PontosAcessoController < ApplicationController
  before_action :exigir_login
  before_action :exigir_perfil_operador

  def new
    @restaurantes = Restaurant.ativos.order(:name)
  end

  def create
    restaurante = Restaurant.find_by(id: params[:restaurant_id])

    if params[:restaurant_id].blank?
      recusar("Selecione um restaurante para continuar")
    elsif restaurante.nil? || !restaurante.ativo?
      recusar("Restaurante indisponível para operação")
    else
      session[:restaurant_id] = restaurante.id
      redirect_to operacao_path, notice: "Ponto de acesso configurado"
    end
  end

  private

  def recusar(mensagem)
    @restaurantes = Restaurant.ativos.order(:name)
    flash.now[:alert] = mensagem
    render :new, status: :unprocessable_entity
  end
end
