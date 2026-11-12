class AddSaldoToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :saldo, :decimal, precision: 8, scale: 2, null: false, default: 0
  end
end
