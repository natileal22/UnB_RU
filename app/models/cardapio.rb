class Cardapio < ApplicationRecord
  has_many :itens, class_name: 'ItemCardapio', dependent: :destroy

  enum :refeicao, { cafe: 'cafe', almoco: 'almoco', jantar: 'jantar' }, validate: true

  validates :data, presence: true
  validates :refeicao, uniqueness: { scope: :data, message: 'já tem cardápio cadastrado nesta data' }

  # Itens na ordem em que devem aparecer na tela: Padrão, Ovolactovegetariano, Vegetariano Estrito.
  def itens_ordenados
    itens.sort_by { |item| ItemCardapio::TIPOS.keys.index(item.tipo.to_sym) }
  end
end