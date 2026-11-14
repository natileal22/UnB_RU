# frozen_string_literal: true

# campos do mer que faltavam no restaurante
class AddDadosToRestaurants < ActiveRecord::Migration[8.1]
  def change
    add_column :restaurants, :localizacao, :string
    add_column :restaurants, :capacidade, :integer
    add_column :restaurants, :horario_abertura, :time
    add_column :restaurants, :horario_fechamento, :time
  end
end
