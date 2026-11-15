# frozen_string_literal: true

module Operador
  # historico local da catraca so para funcionario
  class HistoricoController < ApplicationController
    layout 'operador'

    before_action :exigir_login
    before_action :exigir_funcionario

    def index
      @resultado = HistoricoLocal.new(usuario: current_user, **filtro).call
      return if @resultado.valido?

      flash.now[:alert] = @resultado.mensagem
      render :index, status: :unprocessable_content
    end

    private

    # admin tambem e operador mas a pagina e so do funcionario
    def exigir_funcionario
      return if current_user.perfil == 'funcionario'

      render 'operador/historico/acesso_negado', status: :forbidden
    end

    def filtro
      params.permit(:data_inicial, :data_final, :resultado).to_h.symbolize_keys
    end
  end
end
