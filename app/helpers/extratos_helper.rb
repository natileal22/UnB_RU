# frozen_string_literal: true

# formatacao do valor em reais na tela de extrato
module ExtratosHelper
  def valor_br(valor)
    number_to_currency(valor, unit: 'R$', format: '%u %n', separator: ',', delimiter: '.')
  end

  # cor do selo da recarga e o nome do status ja serve de classe
  def tipo_do_selo(recarga)
    { 'aprovada' => 'ok', 'recusada' => 'erro' }.fetch(recarga.status, 'pendente')
  end
end
