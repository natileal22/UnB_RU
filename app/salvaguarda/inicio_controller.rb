# frozen_string_literal: true

# reserva da pagina inicial enquanto a tela Inicio e Carteira da Natalia nao chega
class InicioController < ApplicationController
  # cada perfil cai na tela que ja existe e so o visitante e o estudante veem a home
  DESTINOS = { 'funcionario' => :ponto_acesso_path, 'administrador' => :admin_restaurantes_path }.freeze

  # pagina inicial de cada perfil
  # args: nenhum, o perfil vem da sessao
  # retorna: funcionario e administrador sao redirecionados, o estudante ve a carteira e o visitante a porta de entrada
  # efeito: redireciona ou renderiza, nao grava nada
  def show
    destino = DESTINOS[current_user&.perfil]
    return redirect_to public_send(destino) if destino

    mostrar_carteira if current_user
  end

  # o sair do operador leva ao login do operador entao o estudante tem o dele
  # args: nenhum
  # retorna: redireciona para a pagina inicial
  # efeito: apaga a sessao do usuario
  def sair
    session.delete(:user_id)
    redirect_to root_path
  end

  private

  # monta a carteira do estudante com o turno e o cardapio da refeicao atual
  # args: nenhum
  # retorna: renderiza carteira no layout do estudante
  # efeito: so le o banco, o cardapio vem da reserva e nao da api
  def mostrar_carteira
    @refeicao = HorarioRefeicao.atual
    @proxima = HorarioRefeicao.proxima
    @cardapio = CardapioDoDia.new.da_reserva(@refeicao, Time.zone.today) if @refeicao
    @refeicoes_garantidas = current_user.saldo.div(ValidacaoEntrada::PRECO)
    render :carteira, layout: 'estudante'
  end
end
