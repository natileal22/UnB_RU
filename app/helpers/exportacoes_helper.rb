# frozen_string_literal: true

# link de volta ao relatorio global com os mesmos filtros da exportacao
module ExportacoesHelper
  # caminho de volta ao relatorio global com os mesmos filtros
  # args: nenhum, os filtros vem de params
  # retorna: caminho (String) com restaurante, catraca e datas quando validos
  # efeito: nenhum
  def caminho_voltar_relatorio
    filtros = { restaurant_id: params[:restaurant_id].presence, catraca: params[:catraca].presence }
    admin_relatorio_path(filtros.merge(datas_do_relatorio).compact)
  end

  private

  # o relatorio usa data iso e a exportacao dd/mm/aaaa, e periodo invalido nao volta
  # args: nenhum, as datas vem de params
  # retorna: hash com date_from e date_to, vazio quando o periodo e invalido
  # efeito: nenhum
  def datas_do_relatorio
    periodo = PeriodoFiltro.new(data_inicial: params[:data_inicial], data_final: params[:data_final]).call
    return {} unless periodo.valido?

    { date_from: periodo.inicio&.iso8601, date_to: periodo.fim&.iso8601 }
  end
end
