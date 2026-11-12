class AddPerfilToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :perfil, :string, default: "estudante", null: false
  end
end