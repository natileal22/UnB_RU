class AddStatusToRestaurants < ActiveRecord::Migration[8.1]
  def change
    add_column :restaurants, :status, :string, null: false, default: "ativo"
  end
end