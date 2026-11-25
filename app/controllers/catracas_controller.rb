# Controller do terminal de validação de entrada (issue #6).
#
# Exibe a tela da catraca e processa a tentativa de entrada do estudante.
# Não exige login de operador: o terminal é acessado diretamente pelo código da catraca.
class CatracasController < ApplicationController
  layout "operador"
  before_action :carregar_catraca
  before_action :carregar_ultimas_validacoes

  # Exibe a tela do terminal de validação com o formulário de matrícula.
  #
  # ==== Argumentos
  # Nenhum. Usa +params[:id]+ carregado pelo +before_action+.
  #
  # ==== Retorno
  # Renderiza +catracas/show+ com status 200.
  #
  # ==== Efeitos colaterais
  # Nenhum.
  def show
  end

  # Processa a tentativa de entrada: valida a matrícula e debita o saldo se liberada.
  #
  # ==== Argumentos
  # Nenhum. Usa +params[:matricula]+ e +session[:restaurant_id]+.
  #
  # ==== Retorno
  # Renderiza +catracas/show+ com status 200 (entrada liberada) ou 422 (entrada negada).
  # A variável de instância +@resultado+ fica disponível para a view.
  #
  # ==== Efeitos colaterais
  # Chama +ValidacaoEntrada#call+, que grava um registro em +accesses+ e pode debitar o saldo.
  def entrada
    @resultado = ValidacaoEntrada.new(
      catraca: @catraca,
      matricula: params[:matricula],
      restaurante_selecionado_id: session[:restaurant_id]
    ).call

    render :show, status: (@resultado.liberado? ? :ok : :unprocessable_entity)
  end

  private

  # Carrega a catraca pelo id da rota. Levanta +ActiveRecord::RecordNotFound+ (404) se inexistente.
  #
  # ==== Argumentos
  # Nenhum. Usa +params[:id]+.
  #
  # ==== Retorno
  # Nenhum. Atribui +@catraca+.
  #
  # ==== Efeitos colaterais
  # Atribui +@catraca+. Encerra a requisição com 404 se não encontrada.
  def carregar_catraca
    @catraca = Catraca.find(params[:id])
  end

  # Carrega as últimas 10 validações da catraca em ordem decrescente de horário.
  #
  # ==== Argumentos
  # Nenhum. Depende de +@catraca+ atribuída pelo +before_action+ anterior.
  #
  # ==== Retorno
  # Nenhum. Atribui +@ultimas_validacoes+.
  #
  # ==== Efeitos colaterais
  # Atribui +@ultimas_validacoes+.
  def carregar_ultimas_validacoes
    @ultimas_validacoes = @catraca.acessos.recent_first.limit(10)
  end
end
