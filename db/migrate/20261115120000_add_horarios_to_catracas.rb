# frozen_string_literal: true

# horario de funcionamento opcional da catraca (campos do mer)
class AddHorariosToCatracas < ActiveRecord::Migration[8.1]
  def change
    add_column :catracas, :horario_abertura, :time
    add_column :catracas, :horario_fechamento, :time
  end
end
