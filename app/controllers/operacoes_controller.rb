# frozen_string_literal: true

# Controller da tela de Operação (issue #5).
#
# Exibe o painel do restaurante em operação com as catracas disponíveis.
# Redireciona para o ponto de acesso quando nenhum restaurante está selecionado na sessão.
class OperacoesController < ApplicationController
  layout 'operador'
  before_action :exigir_login
  before_action :exigir_perfil_operador

  # Exibe o painel de operação do restaurante selecionado na sessão.
  #
  # ==== Argumentos
  # Nenhum. Usa +session[:restaurant_id]+.
  #
  # ==== Retorno
  # Renderiza +operacoes/show+ com status 200 quando há restaurante ativo na sessão.
  # Redireciona para +ponto_acesso_path+ com flash +:alert+ quando o restaurante não está disponível.
  # A variável +@restaurante+ fica disponível para a view.
  #
  # ==== Efeitos colaterais
  # Nenhum.
  def show
    @restaurante = Restaurant.ativos.find_by(id: session[:restaurant_id])
    return if @restaurante

    redirect_to ponto_acesso_path, alert: 'Selecione um restaurante para continuar'
  end
end
