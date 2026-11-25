# Controller da Configuração do Ponto de Acesso (issue #5).
#
# Permite ao operador (funcionário ou administrador) selecionar o restaurante
# que será operado na sessão atual antes de usar o terminal de validação.
class PontosAcessoController < ApplicationController
  layout "operador"
  before_action :exigir_login
  before_action :exigir_perfil_operador

  # Exibe o formulário de seleção de restaurante.
  #
  # ==== Argumentos
  # Nenhum.
  #
  # ==== Retorno
  # Renderiza +pontos_acesso/new+ com status 200.
  # A variável +@restaurantes+ contém os restaurantes ativos ordenados por nome.
  #
  # ==== Efeitos colaterais
  # Nenhum.
  def new
    @restaurantes = Restaurant.ativos.order(:name)
  end

  # Processa a seleção de restaurante e inicia a sessão de operação.
  #
  # ==== Argumentos
  # Nenhum. Usa +params[:restaurant_id]+.
  #
  # ==== Retorno
  # Redireciona para +operacao_path+ com flash +:notice+ "Ponto de acesso configurado" em caso de sucesso.
  # Renderiza +pontos_acesso/new+ com status 422 e flash +:alert+ em caso de falha.
  #
  # ==== Efeitos colaterais
  # Em caso de sucesso, grava +session[:restaurant_id]+ com o id do restaurante selecionado.
  def create
    return recusar("Selecione um restaurante para continuar") if params[:restaurant_id].blank?

    restaurante = restaurante_operacional(params[:restaurant_id])
    return recusar("Restaurante indisponível para operação") unless restaurante

    session[:restaurant_id] = restaurante.id
    redirect_to operacao_path, notice: "Ponto de acesso configurado"
  end

  private

  # Busca o restaurante pelo id e retorna-o somente se estiver ativo.
  #
  # ==== Argumentos
  # * +id+ — valor de +params[:restaurant_id]+.
  #
  # ==== Retorno
  # O objeto +Restaurant+ ativo, ou +nil+ se não encontrado ou inativo.
  #
  # ==== Efeitos colaterais
  # Nenhum.
  def restaurante_operacional(id)
    r = Restaurant.find_by(id: id)
    r if r&.ativo?
  end

  # Carrega a lista de restaurantes ativos, registra a mensagem de erro e re-renderiza o formulário.
  #
  # ==== Argumentos
  # * +mensagem+ — string com o texto do alerta a exibir ao usuário.
  #
  # ==== Retorno
  # Renderiza +pontos_acesso/new+ com status 422.
  #
  # ==== Efeitos colaterais
  # Atribui +@restaurantes+. Define +flash.now[:alert]+ com a mensagem recebida.
  def recusar(mensagem)
    @restaurantes = Restaurant.ativos.order(:name)
    flash.now[:alert] = mensagem
    render :new, status: :unprocessable_entity
  end
end
