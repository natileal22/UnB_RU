# frozen_string_literal: true

# formatacao do valor em reais na tela de extrato
module ExtratosHelper
  def valor_br(valor)
    number_to_currency(valor, unit: 'R$', format: '%u %n', separator: ',', delimiter: '.')
  end
end
