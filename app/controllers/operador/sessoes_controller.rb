# frozen_string_literal: true

module Operador
  # Controla a autenticação e o encerramento de sessão dos operadores do RU.
  class SessoesController < ApplicationController
    layout 'operador'

    def new; end

    def create
      return render_erro('Preencha todos os campos obrigatórios') if credenciais_em_branco?

      user = autenticar_operador
      return render_erro('Credenciais inválidas') unless user

      session[:user_id] = user.id
      redirect_to admin_restaurantes_path, notice: 'Sessão autenticada com sucesso'
    end

    def destroy
      session.delete(:user_id)
      redirect_to operador_entrar_path
    end

    private

    def credenciais_em_branco?
      params[:matricula].to_s.strip.blank? || params[:senha].to_s.blank?
    end

    def autenticar_operador
      user = User.find_by(matricula: params[:matricula].to_s.strip)
      user if user&.operador_autorizado? && user.authenticate(params[:senha].to_s)
    end

    def render_erro(mensagem)
      flash.now[:alert] = mensagem
      render :new, status: :unprocessable_content
    end
  end
end