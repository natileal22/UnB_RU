class CreateItensCardapio < ActiveRecord::Migration[8.1]
  def change
    create_table :itens_cardapio do |t|
      t.references :cardapio, null: false, foreign_key: true
      t.string :tipo, null: false
      t.string :item, null: false

      t.timestamps
    end
  end
end