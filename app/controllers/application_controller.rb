# Controller base da aplicação. Define helpers de sessão e filtros compartilhados.
#
# Os métodos +exigir_login+ e +exigir_perfil_operador+ protegem as rotas
# da Configuração do Ponto de Acesso (issue #5).
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

  # Exige que o usuário esteja autenticado; redireciona para o login do operador caso contrário.
  #
  # ==== Argumentos
  # Nenhum.
  #
  # ==== Retorno
  # Nenhum quando o usuário está logado. Redireciona para +operador_entrar_path+ com
  # flash +:alert+ "Faça login para continuar" quando não há sessão.
  #
  # ==== Efeitos colaterais
  # Pode redirecionar a requisição, encerrando o processamento do controller.
  def exigir_login
    redirect_to operador_entrar_path, alert: 'Faça login para continuar' unless current_user
  end

  # Exige que o usuário autenticado seja operador; renderiza a tela de acesso negado caso contrário.
  #
  # ==== Argumentos
  # Nenhum.
  #
  # ==== Retorno
  # Nenhum quando o usuário é operador autorizado. Renderiza +shared/acesso_negado+
  # com status 403 quando o perfil não é "funcionario" nem "administrador".
  #
  # ==== Efeitos colaterais
  # Pode renderizar +shared/acesso_negado+ com status 403, encerrando o processamento.
  def exigir_perfil_operador
    return if current_user&.operador_autorizado?

    render 'shared/acesso_negado', status: :forbidden
  end
end
