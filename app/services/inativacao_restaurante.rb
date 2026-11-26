# frozen_string_literal: true

# inativa o restaurante e as catracas ativas e deixa as em manutencao como estao
class InativacaoRestaurante
  Resultado = Struct.new(:mensagem, keyword_init: true)

  # prepara a inativacao de um restaurante
  # args: restaurante (Restaurant)
  # retorna: a instancia
  # efeito: nenhum
  def initialize(restaurante:)
    @restaurante = restaurante
  end

  # inativa o restaurante e as catracas ativas, as em manutencao ficam como estao
  # args: nenhum
  # retorna: Resultado com a mensagem de sucesso
  # efeito: grava o status no restaurante e nas catracas dentro de uma transacao
  def call
    Restaurant.transaction do
      @restaurante.catracas.where(status: 'ativa').update_all(status: 'inativa', updated_at: Time.current)
      @restaurante.update!(status: 'inativo')
    end
    Resultado.new(mensagem: 'Restaurante e suas catracas ativas foram inativados')
  end
end
