# frozen_string_literal: true

# views de reserva ficam no fim da busca entao a view real de um colega em app/views vence sozinha
ActiveSupport.on_load(:action_controller) do
  append_view_path Rails.root.join('app/salvaguarda/views')
end
