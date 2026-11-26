# frozen_string_literal: true

# cor do selo de status de restaurante e catraca na tela de gestao
module GestaoHelper
  # cor do selo de status de restaurante e catraca
  # args: status (String)
  # retorna: ok, erro ou pendente, pendente para o que nao e ativo nem inativo
  # efeito: nenhum
  def tipo_do_status(status)
    { 'ativo' => 'ok', 'ativa' => 'ok', 'inativo' => 'erro', 'inativa' => 'erro' }.fetch(status, 'pendente')
  end
end
