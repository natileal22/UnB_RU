class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :matricula, null: false
      t.string :email
      t.string :password_digest, null: false

      t.timestamps
    end
    add_index :users, :matricula, unique: true
  end
end
