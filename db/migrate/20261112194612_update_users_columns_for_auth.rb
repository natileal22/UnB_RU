class UpdateUsersColumnsForAuth < ActiveRecord::Migration[8.1]
  def change
    rename_column :users, :name, :nome
  end
end