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

  def filtered_accesses
    relation = Access.includes(:restaurant).recent_first
    relation = relation.where(restaurant_id: @filters[:restaurant_id]) if @filters[:restaurant_id].present?
    relation = relation.where(catraca: @filters[:catraca]) if @filters[:catraca].present?
    relation = relation.where(resultado: @filters[:resultado]) if @filters[:resultado].present?
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
    return if session[:role].blank? || session[:role].to_s.casecmp("Administrador").zero?

    render plain: "Acesso negado: apenas o Administrador pode realizar esta ação", status: :forbidden
  end
end
