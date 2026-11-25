# frozen_string_literal: true

# Recarga de saldo do estudante (issue #2).
#
# Permite ao estudante logado adicionar créditos à própria conta por PIX ou
# por cartão de crédito. O pagamento é simulado: no PIX o botão "Já paguei"
# faz o papel do aviso do banco e, no cartão, quem decide é o GatewayCartao.
class RecargasController < ApplicationController
  before_action :exigir_estudante
  before_action :carregar_recarga_pix, only: %i[show confirmar]

  # Mostra o formulário de recarga.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum valor útil; renderiza a tela +new+.
  # Efeitos colaterais::
  #   Nenhum. Só prepara uma recarga em memória (+@recarga+), sem gravar no banco.
  def new
    @recarga = current_user.recargas.new
  end

  # Recebe o formulário de recarga e encaminha para o método de pagamento escolhido.
  #
  # Argumentos::
  #   Nenhum argumento direto (é uma action). Lê do formulário
  #   <tt>params[:recarga]</tt>, com +valor+ e +metodo+ (+pix+ ou +cartao_credito+),
  #   e, no cartão, <tt>params[:cartao]</tt>.
  # Retorno::
  #   Nenhum valor útil. A resposta ao navegador depende do caso:
  #   - Valor inválido: renderiza a tela +new+ com status 422 e a mensagem de erro.
  #   - PIX: segue para +criar_pix+, que redireciona para a tela do código PIX.
  #   - Cartão: segue para +processar_cartao+, que aprova, recusa ou mostra erro.
  # Efeitos colaterais::
  #   No caminho válido, grava a recarga no banco (pelos métodos auxiliares) e
  #   redireciona. Com valor inválido, nada é gravado.
  def create
    @recarga = current_user.recargas.new(recarga_params)
    return render_erro(@recarga.errors.full_messages.first) unless @recarga.valid?

    @recarga.pix? ? criar_pix : processar_cartao
  end

  # Mostra a tela do PIX com o código copia e cola, aguardando o pagamento.
  #
  # Argumentos::
  #   Nenhum argumento direto. Usa <tt>params[:id]</tt>, já carregado em
  #   +@recarga+ pelo filtro +carregar_recarga_pix+.
  # Retorno:: nenhum valor útil; renderiza a tela +show+.
  # Efeitos colaterais::
  #   Nenhum. Se a recarga não for um PIX pendente do próprio estudante, o
  #   filtro responde 404 antes de chegar aqui.
  def show; end

  # Simula o aviso do banco de que o PIX foi pago e credita o saldo.
  #
  # Argumentos::
  #   Nenhum argumento direto. Usa a recarga de <tt>params[:id]</tt>, carregada
  #   em +@recarga+ pelo filtro +carregar_recarga_pix+.
  # Retorno:: nenhum valor útil.
  # Efeitos colaterais::
  #   - Altera o banco: aprova a recarga e soma o valor ao saldo (Recarga#aprovar!).
  #   - Redireciona para a tela de recarga com "Pagamento confirmado!" e o saldo atual.
  def confirmar
    @recarga.aprovar!
    redirect_to nova_recarga_path, notice: "Pagamento confirmado! #{texto_saldo}"
  end

  private

  # Filtra os campos da recarga enviados pelo formulário (strong parameters).
  #
  # Argumentos:: nenhum; lê <tt>params[:recarga]</tt>.
  # Retorno::
  #   +ActionController::Parameters+ só com +valor+ e +metodo+. Se o formulário
  #   não enviou <tt>:recarga</tt>, retorna parâmetros vazios em vez de dar erro.
  # Efeitos colaterais:: nenhum.
  def recarga_params
    params.fetch(:recarga, {}).permit(:valor, :metodo)
  end

  # Monta os dados do cartão enviados pelo formulário.
  #
  # Argumentos:: nenhum; lê <tt>params[:cartao]</tt>.
  # Retorno::
  #   +Hash+ com as chaves +:numero+, +:nome+, +:validade+ e +:cvv+. As chaves
  #   que o formulário não enviou vêm com +nil+, para o GatewayCartao sempre
  #   receber as quatro.
  # Efeitos colaterais:: nenhum.
  def dados_cartao
    campos = params.fetch(:cartao, {}).permit(:numero, :nome, :validade, :cvv).to_h.symbolize_keys
    { numero: nil, nome: nil, validade: nil, cvv: nil }.merge(campos)
  end

  # Gera o código PIX da recarga e a deixa pendente de pagamento.
  #
  # Argumentos:: nenhum; usa +@recarga+, já validada em +create+.
  # Retorno:: nenhum valor útil.
  # Efeitos colaterais::
  #   - Altera o banco: grava a recarga com status +pendente+ e o código PIX.
  #   - Redireciona para a tela do PIX (+show+). O saldo ainda não muda.
  def criar_pix
    @recarga.codigo_pix = "PIX-UNBRU-#{SecureRandom.hex(8).upcase}"
    @recarga.save!
    redirect_to recarga_path(@recarga)
  end

  # Valida os dados do cartão e, se estiverem corretos, registra e cobra a recarga.
  #
  # Argumentos:: nenhum; usa +@recarga+ e os dados de +dados_cartao+.
  # Retorno:: nenhum valor útil.
  # Efeitos colaterais::
  #   - Dados inválidos: renderiza +new+ com status 422 e "Dados do cartão
  #     inválidos". Nada é gravado.
  #   - Dados válidos: grava a recarga no banco e segue para +cobrar_cartao+,
  #     que aprova ou recusa a compra.
  def processar_cartao
    dados = dados_cartao
    return render_erro('Dados do cartão inválidos') unless GatewayCartao.dados_validos?(dados)

    @recarga.save!
    cobrar_cartao(dados[:numero])
  end

  # Pede a autorização da compra à operadora e conclui a recarga com a resposta.
  #
  # Argumentos::
  #   +numero+ - número do cartão, já validado por +processar_cartao+.
  # Retorno:: nenhum valor útil.
  # Efeitos colaterais::
  #   - Autorizada: aprova a recarga e credita o saldo no banco, e redireciona
  #     com "Compra aprovada!" e o saldo atual.
  #   - Recusada: marca a recarga como +recusada+ no banco (o saldo não muda) e
  #     redireciona com "Compra recusada: cartão sem limite disponível".
  def cobrar_cartao(numero)
    if GatewayCartao.autorizar(numero: numero)
      @recarga.aprovar!
      redirect_to nova_recarga_path, notice: "Compra aprovada! #{texto_saldo}"
    else
      @recarga.recusar!
      redirect_to nova_recarga_path, alert: 'Compra recusada: cartão sem limite disponível'
    end
  end

  # Mostra de novo o formulário de recarga com uma mensagem de erro.
  #
  # Argumentos::
  #   +mensagem+ - texto do erro exibido no topo da tela.
  # Retorno:: nenhum valor útil.
  # Efeitos colaterais::
  #   Renderiza a tela +new+ com status 422 (Unprocessable Content). Não grava nada.
  def render_erro(mensagem)
    flash.now[:alert] = mensagem
    render :new, status: :unprocessable_content
  end

  # Filtro que carrega a recarga PIX pendente do estudante logado.
  #
  # Argumentos:: nenhum; lê <tt>params[:id]</tt>.
  # Retorno:: a Recarga encontrada, guardada em +@recarga+.
  # Efeitos colaterais::
  #   Se a recarga não existir, não for PIX, já tiver sido processada ou for de
  #   outro estudante, lança +ActiveRecord::RecordNotFound+ e o Rails responde 404.
  #   É isso que impede confirmar duas vezes ou confirmar a recarga de outra pessoa.
  def carregar_recarga_pix
    @recarga = current_user.recargas.pix.pendente.find(params[:id])
  end

  # Monta o texto com o saldo atualizado do estudante.
  #
  # Argumentos:: nenhum.
  # Retorno:: +String+ no formato "Saldo atual: R$ 20,00".
  # Efeitos colaterais::
  #   Recarrega o usuário do banco (+reload+) para mostrar o saldo já creditado.
  #   Não altera nada.
  def texto_saldo
    "Saldo atual: #{helpers.number_to_currency(current_user.reload.saldo)}"
  end

  # Filtro que garante que só estudantes logados usem a recarga (RN07).
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum valor útil.
  # Efeitos colaterais::
  #   - Sem login: redireciona para a autenticação com "Faça login para continuar".
  #   - Logado sem perfil de estudante (funcionário ou administrador): renderiza
  #     a tela "esta página é exclusiva do estudante" com status 403, a mesma do extrato.
  #   - Estudante logado: não faz nada e a action segue normalmente.
  def exigir_estudante
    return redirect_to login_path, alert: 'Faça login para continuar' unless current_user
    return if current_user.perfil == 'estudante'

    render 'extratos/acesso_negado', status: :forbidden
  end
end
