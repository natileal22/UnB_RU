class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(matricula: params[:matricula].to_s.strip)

    if user&.authenticate(params[:password].to_s)
      iniciar_sessao(user)
    else
      flash.now[:alert] = "Matrícula ou senha inválidas"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def iniciar_sessao(user)
    reset_session
    session[:user_id] = user.id
    redirect_to destino_apos_login(user)
  end

  def destino_apos_login(user)
    user.operador_autorizado? ? ponto_acesso_path : root_path
  end
end
