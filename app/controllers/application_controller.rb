class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  # Autenticação do operador (issue do Pedro): redireciona quem não é funcionário/administrador.
  def exigir_operador!
    return if current_user&.operador_autorizado?

    redirect_to operador_entrar_path, alert: 'Acesso restrito a funcionários.'
  end

  # Configuração do ponto de acesso (issue #5): sem login vai para a autenticação do operador.
  def exigir_login
    redirect_to operador_entrar_path, alert: 'Faça login para continuar' unless current_user
  end

  # Configuração do ponto de acesso (issue #5): logado, mas sem perfil de operador, vê a mensagem de acesso negado.
  def exigir_perfil_operador
    return if current_user&.operador_autorizado?

    render 'shared/acesso_negado', status: :forbidden
  end
end
