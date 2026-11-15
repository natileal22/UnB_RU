# frozen_string_literal: true

# guarda de administrador e carga da tela de gestao de restaurantes e catracas
module GestaoAdministrativa
  extend ActiveSupport::Concern

  included do
    layout 'administracao'

    before_action :exigir_login
    # a listagem tambem abre para funcionario e o resto so para administrador
    before_action :exigir_operador!, if: :listagem?
    before_action :exigir_administrador, unless: :listagem?
  end

  private

  def listagem?
    action_name == 'index'
  end

  def exigir_administrador
    return if current_user.perfil == 'administrador'

    render 'admin/acesso_negado', status: :forbidden
  end

  def renderizar_gestao(status: :ok)
    @restaurantes = Restaurant.includes(catracas: :responsavel).order(Arel.sql('LOWER(restaurants.name)'))
    @responsaveis = User.where(perfil: %w[funcionario administrador]).order(:nome)
    @novo_restaurante ||= Restaurant.new
    @nova_catraca ||= Catraca.new
    render 'admin/restaurantes/index', status: status
  end

  def falha_de_validacao(registro)
    flash.now[:alert] = registro.errors.first.message
    renderizar_gestao(status: :unprocessable_content)
  end
end
