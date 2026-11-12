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

  def exigir_login
    redirect_to login_path, alert: "Faça login para continuar" unless current_user
  end

  def exigir_operador
    return if current_user&.operador?

    render "shared/acesso_negado", status: :forbidden
  end
end