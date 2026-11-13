class OperacoesController < ApplicationController
  before_action :exigir_login
  before_action :exigir_perfil_operador

  def show
    @restaurante = Restaurant.ativos.find_by(id: session[:restaurant_id])
    return if @restaurante

    redirect_to ponto_acesso_path, alert: "Selecione um restaurante para continuar"
  end
end
