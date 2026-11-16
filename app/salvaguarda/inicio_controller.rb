# frozen_string_literal: true

# reserva da pagina inicial enquanto a tela Inicio e Carteira da Natalia nao chega
class InicioController < ApplicationController
  # cada perfil cai na tela que ja existe e so o visitante e o estudante veem a home
  def show
    case current_user&.perfil
    when 'funcionario' then redirect_to ponto_acesso_path
    when 'administrador' then redirect_to admin_restaurantes_path
    when 'estudante' then mostrar_carteira
    end
  end

  # o sair do operador leva ao login do operador entao o estudante tem o dele
  def sair
    session.delete(:user_id)
    redirect_to root_path
  end

  private

  # mesmos dados do cardapio da refeicao atual que o CardapiosController usa
  def mostrar_carteira
    @refeicao = HorarioRefeicao.atual
    @proxima = HorarioRefeicao.proxima
    @cardapio = Cardapio.includes(:itens).find_by(data: Time.zone.today, refeicao: @refeicao.chave) if @refeicao
    @refeicoes_garantidas = (current_user.saldo / ValidacaoEntrada::PRECO).floor
    render :carteira, layout: 'estudante'
  end
end
