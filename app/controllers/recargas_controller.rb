class RecargasController < ApplicationController
  before_action :exigir_estudante
  before_action :carregar_recarga_pix, only: %i[show confirmar]

  def new
    @recarga = current_user.recargas.new
  end

  def create
    @recarga = current_user.recargas.new(recarga_params)
    return render_erro(@recarga.errors.full_messages.first) unless @recarga.valid?

    if @recarga.pix?
      criar_pix
    else
      processar_cartao
    end
  end

  # Tela do PIX com o código copia e cola, aguardando o pagamento.
  def show; end

  # Simula o aviso do banco de que o PIX foi pago.
  def confirmar
    @recarga.aprovar!
    redirect_to nova_recarga_path, notice: "Pagamento confirmado! #{texto_saldo}"
  end

  private

  def recarga_params
    params.fetch(:recarga, {}).permit(:valor, :metodo)
  end

  def cartao_params
    params.fetch(:cartao, {}).permit(:numero, :nome, :validade, :cvv).to_h.symbolize_keys
  end

  def criar_pix
    @recarga.codigo_pix = "PIX-UNBRU-#{SecureRandom.hex(8).upcase}"
    @recarga.save!
    redirect_to recarga_path(@recarga)
  end

  def processar_cartao
    dados = { numero: nil, nome: nil, validade: nil, cvv: nil }.merge(cartao_params)
    return render_erro('Dados do cartão inválidos') unless GatewayCartao.dados_validos?(**dados)

    @recarga.save!
    if GatewayCartao.autorizar(numero: dados[:numero])
      @recarga.aprovar!
      redirect_to nova_recarga_path, notice: "Compra aprovada! #{texto_saldo}"
    else
      @recarga.recusar!
      redirect_to nova_recarga_path, alert: 'Compra recusada: cartão sem limite disponível'
    end
  end

  def render_erro(mensagem)
    flash.now[:alert] = mensagem
    render :new, status: :unprocessable_content
  end

  def carregar_recarga_pix
    @recarga = current_user.recargas.pix.pendente.find(params[:id])
  end

  def texto_saldo
    "Saldo atual: #{helpers.number_to_currency(current_user.reload.saldo)}"
  end

  def exigir_estudante
    redirect_to login_path, alert: 'Faça login para continuar' unless current_user
  end
end