class CreateCatracas < ActiveRecord::Migration[8.1]
  def change
    create_table :catracas do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.string :codigo, null: false
      t.string :status, null: false, default: "ativa"

      t.timestamps
    end
    add_index :catracas, %i[restaurant_id codigo], unique: true
  end
end