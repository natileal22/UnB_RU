# frozen_string_literal: true

# Cardápio de uma refeição (café, almoço ou jantar) em uma data.
#
# Cada refeição tem no máximo um cardápio por dia (RN06). Os pratos ficam em
# ItemCardapio, um por tipo: Padrão, Ovolactovegetariano e Vegetariano Estrito.
class Cardapio < ApplicationRecord
  has_many :itens, class_name: 'ItemCardapio', dependent: :destroy

  enum :refeicao, { cafe: 'cafe', almoco: 'almoco', jantar: 'jantar' }, validate: true

  validates :data, presence: true
  validates :refeicao, uniqueness: { scope: :data, message: 'já tem cardápio cadastrado nesta data' }

  # Lista os itens do cardápio na ordem em que aparecem na tela (RN02).
  #
  # Argumentos:: nenhum.
  # Retorno::
  #   +Array+ de ItemCardapio na ordem Padrão, Ovolactovegetariano, Vegetariano
  #   Estrito. Se o cardápio não tiver itens, retorna um array vazio.
  # Efeitos colaterais::
  #   Nenhum. Só lê os itens (e os carrega do banco se ainda não estiverem em memória).
  def itens_ordenados
    itens.sort_by { |item| ItemCardapio::TIPOS.keys.index(item.tipo.to_sym) }
  end
end
