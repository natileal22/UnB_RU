module Admin
  class RestaurantesController < ApplicationController
    before_action :exigir_operador!

    def index; end
  end
end
