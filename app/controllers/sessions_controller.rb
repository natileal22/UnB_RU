class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(matricula: params[:matricula].to_s.strip)

    if user&.authenticate(params[:password].to_s)
      reset_session
      session[:user_id] = user.id
      redirect_to(user.operador_autorizado? ? ponto_acesso_path : root_path)
    else
      flash.now[:alert] = "Matrícula ou senha inválidas"
      render :new, status: :unprocessable_entity
    end
  end
end
