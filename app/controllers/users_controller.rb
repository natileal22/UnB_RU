class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to login_path, notice: "Cadastro realizado com sucesso"
    elsif matricula_taken?
      flash.now[:alert] = "Matrícula já cadastrada"
      render :new, status: :unprocessable_entity
    elsif matricula_invalid?
      flash.now[:alert] = "Matrícula inválida"
      render :new, status: :unprocessable_entity
    else
      flash.now[:alert] = "Preencha todos os campos obrigatórios"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(user: %i[name matricula password]).fetch(:user, {})
  end

  def matricula_taken?
    @user.errors.details[:matricula].any? { |error| error[:error] == :taken }
  end

  def matricula_invalid?
    @user.errors.details[:matricula].any? do |error|
      %w[invalid format inválida].include?(error[:error].to_s)
    end
  end
end
