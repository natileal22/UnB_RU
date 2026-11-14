# frozen_string_literal: true

# liga a catraca ao funcionario responsavel
class AddResponsavelToCatracas < ActiveRecord::Migration[8.1]
  def change
    add_reference :catracas, :responsavel, null: true, foreign_key: { to_table: :users }
  end
end
