# frozen_string_literal: true

module Operador
  # historico local da catraca so para funcionario
  class HistoricoController < ApplicationController
    layout 'operador'

    before_action :exigir_login
    before_action :exigir_funcionario

    # lista os acessos das catracas vinculadas ao funcionario logado
    # args: nenhum, o periodo e o status vem de params
    # retorna: renderiza index e, com periodo invalido, responde 422 com a mensagem
    # efeito: so le o banco
    def index
      @resultado = HistoricoLocal.new(usuario: current_user, **filtro).call
      return if @resultado.valido?

      flash.now[:alert] = @resultado.mensagem
      render :index, status: :unprocessable_content
    end

    private

    # a pagina e so do funcionario, o administrador tambem e operador mas nao entra
    # args: nenhum
    # retorna: segue para o funcionario, senao renderiza acesso negado com status 403
    # efeito: renderiza e interrompe a acao
    def exigir_funcionario
      return if current_user.perfil == 'funcionario'

      render 'operador/historico/acesso_negado', status: :forbidden
    end

    # so periodo e status entram e o usuario vem sempre da sessao
    # args: nenhum, os dados vem de params
    # retorna: hash com data_inicial, data_final e resultado em simbolos
    # efeito: nenhum
    def filtro
      params.permit(:data_inicial, :data_final, :resultado).to_h.symbolize_keys
    end
  end
end
