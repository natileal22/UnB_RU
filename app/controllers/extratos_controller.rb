# frozen_string_literal: true

# extrato de recargas e historico de refeicoes do estudante logado
class ExtratosController < ApplicationController
  layout 'estudante'

  before_action :exigir_login_do_estudante
  before_action :exigir_estudante

  def index
    @resultado = ExtratoHistorico.new(usuario: current_user, **filtro).call
    return if @resultado.valido?

    flash.now[:alert] = @resultado.erro
    render :index, status: :unprocessable_content
  end

  private

  # o estudante entra pelo login dele e nao pelo do operador
  def exigir_login_do_estudante
    redirect_to login_path, alert: 'Faça login para continuar' unless current_user
  end

  def exigir_estudante
    return if current_user.perfil == 'estudante'

    # o cabecalho do estudante nao serve para quem e do operador
    render 'extratos/acesso_negado', layout: 'application', status: :forbidden
  end

  # so as datas entram e o usuario vem sempre da sessao
  def filtro
    params.permit(:data_inicial, :data_final).to_h.symbolize_keys
  end
end
