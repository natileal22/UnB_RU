class ItemCardapio < ApplicationRecord
  self.table_name = 'itens_cardapio'

  TIPOS = {
    padrao: 'Padrão',
    ovolactovegetariano: 'Ovolactovegetariano',
    vegetariano_estrito: 'Vegetariano Estrito'
  }.freeze

  belongs_to :cardapio

  enum :tipo, TIPOS.keys.index_with(&:to_s), validate: true

  validates :item, presence: true

  def nome_do_tipo
    TIPOS.fetch(tipo.to_sym)
  end
end