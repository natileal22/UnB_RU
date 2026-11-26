# frozen_string_literal: true

# extrato de recargas e historico de refeicoes do estudante logado
class ExtratosController < ApplicationController
  layout 'estudante'

  before_action :exigir_login_do_estudante
  before_action :exigir_estudante

  # lista o extrato de recargas e o historico de refeicoes do estudante logado
  # args: nenhum, o periodo vem de params
  # retorna: renderiza index e, com periodo invalido, responde 422 com a mensagem
  # efeito: so le o banco
  def index
    @resultado = ExtratoHistorico.new(usuario: current_user, **filtro).call
    return if @resultado.valido?

    flash.now[:alert] = @resultado.erro
    render :index, status: :unprocessable_content
  end

  private

  # manda o visitante para o login do estudante e nao para o do operador
  # args: nenhum
  # retorna: segue quando ha usuario, senao redireciona para login_path com alerta
  # efeito: redireciona e interrompe a acao
  def exigir_login_do_estudante
    redirect_to login_path, alert: 'Faça login para continuar' unless current_user
  end

  # barra quem nao e estudante
  # args: nenhum
  # retorna: segue para o estudante, senao renderiza acesso negado com status 403
  # efeito: renderiza no layout application e interrompe a acao
  def exigir_estudante
    return if current_user.perfil == 'estudante'

    # o cabecalho do estudante nao serve para quem e do operador
    render 'extratos/acesso_negado', layout: 'application', status: :forbidden
  end

  # so as datas entram e o usuario vem sempre da sessao
  # args: nenhum, os dados vem de params
  # retorna: hash com data_inicial e data_final em simbolos
  # efeito: nenhum
  def filtro
    params.permit(:data_inicial, :data_final).to_h.symbolize_keys
  end
end
