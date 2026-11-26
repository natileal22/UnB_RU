# frozen_string_literal: true

# converte a data do filtro do relatorio do formato iso para o formato brasileiro
module RelatorioPdfHelper
  # converte a data do formato iso para o brasileiro
  # args: valor (String iso8601)
  # retorna: texto dd/mm/aaaa ou o proprio valor quando nao e uma data
  # efeito: nenhum
  def data_br(valor)
    Date.iso8601(valor.to_s).strftime('%d/%m/%Y')
  rescue Date::Error
    valor
  end
end
