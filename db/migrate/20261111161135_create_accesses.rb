class CreateAccesses < ActiveRecord::Migration[8.1]
  def change
    create_table :accesses do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.string :catraca, null: false
      t.string :matricula, null: false
      t.string :resultado, null: false
      t.datetime :occurred_at, null: false

      t.timestamps
    end
    add_index :accesses, %i[restaurant_id catraca]
    add_index :accesses, :occurred_at
    add_index :accesses, :resultado
  end
end
