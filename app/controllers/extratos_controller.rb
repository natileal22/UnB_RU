# frozen_string_literal: true

# extrato de recargas e historico de refeicoes do estudante logado
class ExtratosController < ApplicationController
  before_action :exigir_login
  before_action :exigir_estudante

  def index
    @resultado = ExtratoHistorico.new(usuario: current_user, **filtro).call
    return if @resultado.valido?

    flash.now[:alert] = @resultado.erro
    render :index, status: :unprocessable_content
  end

  private

  def exigir_estudante
    return if current_user.perfil == 'estudante'

    render 'extratos/acesso_negado', status: :forbidden
  end

  # so as datas entram e o usuario vem sempre da sessao
  def filtro
    params.permit(:data_inicial, :data_final).to_h.symbolize_keys
  end
end
