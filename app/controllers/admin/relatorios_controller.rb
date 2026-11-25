# Apresenta aos administradores o relatório geral de acessos do campus.
class Admin::RelatoriosController < ApplicationController
  before_action :deny_non_administrators

  def show
    @restaurants = Restaurant.order(:name)
    @filters = filter_params
    @accesses = filtered_accesses
    @grouped = grouping_requested?
    @grouped_accesses = grouped_accesses(@accesses) if @grouped
    @total_accesses = @accesses.count
    @released_accesses = @accesses.where(resultado: "LIBERADO").count
    @denied_accesses = @accesses.where(resultado: "NEGADO").count
  end

  private

  def filter_params
    params.permit(:restaurant_id, :catraca, :resultado, :date_from, :date_to, :grouped)
  end

  # Monta a relação de acessos que corresponde aos filtros do relatório.
  # @return [ActiveRecord::Relation<Access>] acessos ordenados do mais recente para o mais antigo.
  # @note Aplica os filtros sob demanda; não altera registros no banco.
  def filtered_accesses
    relation = Access.includes(:restaurant).recent_first
    relation = apply_exact_filters(relation)
    apply_date_filters(relation)
  end

  # Aplica filtros de correspondência exata para restaurante, catraca e resultado.
  # @param relation [ActiveRecord::Relation<Access>] relação inicial de acessos.
  # @return [ActiveRecord::Relation<Access>] relação limitada pelos filtros informados.
  # @note Não altera registros no banco.
  def apply_exact_filters(relation)
    exact_filters = @filters.slice(:restaurant_id, :catraca, :resultado).to_h.compact_blank
    relation.where(exact_filters)
  end

  # Aplica os limites inclusivos de data inicial e final à relação de acessos.
  # @param relation [ActiveRecord::Relation<Access>] relação inicial de acessos.
  # @return [ActiveRecord::Relation<Access>] relação limitada pelas datas informadas.
  # @note Datas que geram `ArgumentError` ou `TypeError` mantêm o fallback para a época Unix; não altera registros.
  def apply_date_filters(relation)
    relation = relation.where(occurred_at: beginning_of_day(@filters[:date_from])..) if @filters[:date_from].present?
    relation = relation.where(occurred_at: ..end_of_day(@filters[:date_to])) if @filters[:date_to].present?
    relation
  end

  def grouped_accesses(accesses)
    accesses.group_by { |access| [access.restaurant.name, access.catraca] }
             .sort_by { |(restaurant, catraca), _| [restaurant, catraca] }
  end

  def grouping_requested?
    @filters[:grouped] == "1"
  end

  def beginning_of_day(value)
    Time.zone.parse(value.to_s).beginning_of_day
  rescue ArgumentError, TypeError
    Time.zone.at(0)
  end

  def end_of_day(value)
    Time.zone.parse(value.to_s).end_of_day
  rescue ArgumentError, TypeError
    Time.zone.at(0)
  end

  def deny_non_administrators
    return if current_user&.perfil == "administrador"
    return if session[:role].to_s.casecmp("Administrador").zero?

    render plain: "Acesso negado: apenas o Administrador pode realizar esta ação", status: :forbidden
  end
end
