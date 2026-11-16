# frozen_string_literal: true

# inativa o restaurante e as catracas ativas e deixa as em manutencao como estao
class InativacaoRestaurante
  Resultado = Struct.new(:mensagem, keyword_init: true)

  def initialize(restaurante:)
    @restaurante = restaurante
  end

  def call
    Restaurant.transaction do
      @restaurante.catracas.where(status: 'ativa').update_all(status: 'inativa', updated_at: Time.current)
      @restaurante.update!(status: 'inativo')
    end
    Resultado.new(mensagem: 'Restaurante e suas catracas ativas foram inativados')
  end
end
