# Gerencia o cadastro de contas de estudantes.
class UsersController < ApplicationController
  def new
    @user = User.new
  end

  # Cria a conta e redireciona em caso de sucesso.
  # @return [void] redireciona para o login ou renderiza novamente o formulário com erros.
  # @note Persiste o usuário somente quando os atributos enviados são válidos.
  def create
    @user = User.new(user_params)

    return redirect_to login_path, notice: "Cadastro realizado com sucesso" if @user.save

    render_registration_error
  end

  private

  # Exibe o cadastro inválido com a mensagem de validação mais relevante.
  # @return [void] renderiza `new` com o status HTTP 422.
  # @note Define `flash.now[:alert]`; não persiste o usuário.
  def render_registration_error
    flash.now[:alert] = registration_error_message
    render :new, status: :unprocessable_entity
  end

  # Escolhe a mensagem de cadastro com base nos erros da matrícula.
  # @return [String] mensagem de matrícula duplicada, matrícula inválida ou campos obrigatórios.
  # @note Não altera o usuário nem renderiza uma resposta.
  def registration_error_message
    return "Matrícula já cadastrada" if matricula_taken?
    return "Matrícula inválida" if matricula_invalid?

    "Preencha todos os campos obrigatórios"
  end

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
