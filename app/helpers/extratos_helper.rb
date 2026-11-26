# frozen_string_literal: true

# formatacao do valor em reais na tela de extrato
module ExtratosHelper
  # formata um valor em reais
  # args: valor (Numeric)
  # retorna: texto como R$ 4,50
  # efeito: nenhum
  def valor_br(valor)
    number_to_currency(valor, unit: 'R$', format: '%u %n', separator: ',', delimiter: '.')
  end

  # cor do selo da recarga, o nome do status ja serve de classe
  # args: recarga (Recarga)
  # retorna: ok, erro ou pendente
  # efeito: nenhum
  def tipo_do_selo(recarga)
    { 'aprovada' => 'ok', 'recusada' => 'erro' }.fetch(recarga.status, 'pendente')
  end
end
