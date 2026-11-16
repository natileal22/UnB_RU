# frozen_string_literal: true

# converte a data do filtro do relatorio do formato iso para o formato brasileiro
module RelatorioPdfHelper
  def data_br(valor)
    Date.iso8601(valor.to_s).strftime('%d/%m/%Y')
  rescue Date::Error
    valor
  end
end
