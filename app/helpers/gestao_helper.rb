# frozen_string_literal: true

# cor do selo de status de restaurante e catraca na tela de gestao
module GestaoHelper
  def tipo_do_status(status)
    { 'ativo' => 'ok', 'ativa' => 'ok', 'inativo' => 'erro', 'inativa' => 'erro' }.fetch(status, 'pendente')
  end
end
