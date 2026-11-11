class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to login_path, notice: "Cadastro realizado com sucesso"
    elsif @user.errors.added?(:matricula, :taken)
      flash.now[:alert] = "Matrícula já cadastrada"
      render :new, status: :unprocessable_entity
    elsif @user.errors[:matricula].any?
      flash.now[:alert] = "Matrícula inválida"
      render :new, status: :unprocessable_entity
    else
      flash.now[:alert] = "Preencha todos os campos obrigatórios"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.expect(user: %i[name matricula password])
  end
  def new
  end

  def create
  end
end
