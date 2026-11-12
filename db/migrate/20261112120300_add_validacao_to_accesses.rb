class AddValidacaoToAccesses < ActiveRecord::Migration[8.1]
  def change
    add_reference :accesses, :user, null: true, foreign_key: true
    add_column :accesses, :motivo_negacao, :string
    add_column :accesses, :valor_cobrado, :decimal, precision: 6, scale: 2, null: false, default: 0
  end
end