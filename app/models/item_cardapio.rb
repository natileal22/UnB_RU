# frozen_string_literal: true

# Um prato do cardápio, de um dos três tipos de opção do RU.
#
# Os tipos e os nomes exibidos na tela ficam em +TIPOS+.
class ItemCardapio < ApplicationRecord
  self.table_name = 'itens_cardapio'

  # Tipos de opção do cardápio e o nome de cada um na tela, já na ordem de exibição.
  TIPOS = {
    padrao: 'Padrão',
    ovolactovegetariano: 'Ovolactovegetariano',
    vegetariano_estrito: 'Vegetariano Estrito'
  }.freeze

  belongs_to :cardapio

  enum :tipo, TIPOS.keys.index_with(&:to_s), validate: true

  validates :item, presence: true

  # Devolve o nome do tipo do item como aparece na tela.
  #
  # Argumentos:: nenhum; usa o +tipo+ do próprio item.
  # Retorno::
  #   +String+, por exemplo "Vegetariano Estrito" para o tipo +vegetariano_estrito+.
  #   Lança +KeyError+ se o tipo não estiver em +TIPOS+ (o enum já impede isso).
  # Efeitos colaterais:: nenhum.
  def nome_do_tipo
    TIPOS.fetch(tipo.to_sym)
  end
end
