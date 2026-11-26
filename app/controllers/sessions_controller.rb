# frozen_string_literal: true

# Controller de autenticação do estudante (login no portal do estudante).
#
# O login do operador usa Operador::SessoesController.
class SessionsController < ApplicationController
  def new; end

  # Autentica o usuário com matrícula e senha e inicia a sessão.
  #
  # ==== Argumentos
  # Nenhum. Usa +params[:matricula]+ e +params[:password]+.
  #
  # ==== Retorno
  # Redireciona para +ponto_acesso_path+ se o usuário for operador autorizado,
  # ou para +root_path+ se for estudante.
  # Renderiza +sessions/new+ com status 422 e flash +:alert+ se as credenciais forem inválidas.
  #
  # ==== Efeitos colaterais
  # Em caso de sucesso: chama +reset_session+ e grava +session[:user_id]+.
  def create
    user = usuario_autenticado

    if user
      iniciar_sessao(user)
    else
      flash.now[:alert] = 'Matrícula ou senha inválidas'
      render :new, status: :unprocessable_entity
    end
  end

  private

  # Busca o usuário pela matrícula e verifica a senha.
  #
  # ==== Argumentos
  # Nenhum. Usa +params[:matricula]+ e +params[:password]+.
  #
  # ==== Retorno
  # O objeto +User+ se a matrícula existir e a senha estiver correta; +nil+ caso contrário.
  #
  # ==== Efeitos colaterais
  # Nenhum.
  def usuario_autenticado
    user = User.find_by(matricula: params[:matricula].to_s.strip)
    user&.authenticate(params[:password].to_s) || nil
  end

  # Reinicia a sessão, persiste o usuário e redireciona para o destino correto.
  #
  # ==== Argumentos
  # * +user+ — objeto +User+ autenticado.
  #
  # ==== Retorno
  # Redireciona para +destino_apos_login(user)+.
  #
  # ==== Efeitos colaterais
  # Chama +reset_session+ e atribui +session[:user_id]+.
  def iniciar_sessao(user)
    reset_session
    session[:user_id] = user.id
    redirect_to destino_apos_login(user)
  end

  # Decide o caminho de redirecionamento após login bem-sucedido.
  #
  # ==== Argumentos
  # * +user+ — objeto +User+ autenticado.
  #
  # ==== Retorno
  # +ponto_acesso_path+ se o usuário for operador autorizado; +root_path+ caso contrário.
  #
  # ==== Efeitos colaterais
  # Nenhum.
  def destino_apos_login(user)
    user.operador_autorizado? ? ponto_acesso_path : root_path
  end
end
