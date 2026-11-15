class CreateRecargas < ActiveRecord::Migration[8.1]
  def change
    create_table :recargas do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :valor, precision: 8, scale: 2, null: false
      t.string :metodo, null: false
      t.string :status, null: false, default: "pendente"
      t.string :codigo_pix
      
      t.timestamps
    end
  end
end
