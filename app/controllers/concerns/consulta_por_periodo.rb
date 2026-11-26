# frozen_string_literal: true

# fluxo comum das telas que consultam o banco por periodo, o extrato do estudante e o historico da catraca
# o controller que usa define o filtro, que traz so os parametros que a consulta aceita
module ConsultaPorPeriodo
  private

  # roda a consulta do usuario logado e mostra a tela, ou o erro do periodo
  # args: servico (classe do service) que recebe usuario e o filtro e devolve um Resultado com valido? e erro
  # retorna: renderiza index e, com periodo invalido, responde 422 com a mensagem em flash.now
  # efeito: so le o banco
  def consultar(servico)
    @resultado = servico.new(usuario: current_user, **filtro).call
    return if @resultado.valido?

    flash.now[:alert] = @resultado.erro
    render :index, status: :unprocessable_content
  end
end
