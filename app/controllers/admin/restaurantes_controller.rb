# frozen_string_literal: true

module Admin
  # gestao de restaurantes e catracas da issue 8 so para administrador
  class RestaurantesController < ApplicationController
    include GestaoAdministrativa

    before_action :carregar_restaurante, only: %i[edit update destroy ativar inativar]

    def index
      renderizar_gestao
    end

    def new
      renderizar_gestao
    end

    def edit
      @restaurante_em_edicao = @restaurante
      renderizar_gestao
    end

    def create
      @novo_restaurante = Restaurant.new(restaurante_params)
      return falha_de_validacao(@novo_restaurante) unless @novo_restaurante.save(context: :gestao)

      redirect_to admin_restaurantes_path, notice: 'Restaurante cadastrado com sucesso'
    end

    def update
      @restaurante.assign_attributes(restaurante_params)
      if @restaurante.save(context: :gestao)
        return redirect_to admin_restaurantes_path,
                           notice: 'Restaurante atualizado com sucesso'
      end

      @restaurante_em_edicao = @restaurante
      falha_de_validacao(@restaurante)
    end

    def destroy
      motivo = @restaurante.motivo_bloqueio_remocao
      return redirect_to admin_restaurantes_path, alert: motivo if motivo

      @restaurante.destroy!
      redirect_to admin_restaurantes_path, notice: 'Restaurante removido com sucesso'
    end

    def ativar
      @restaurante.update!(status: 'ativo')
      redirect_to admin_restaurantes_path, notice: 'Restaurante ativado com sucesso'
    end

    def inativar
      resultado = InativacaoRestaurante.new(restaurante: @restaurante).call
      redirect_to admin_restaurantes_path, notice: resultado.mensagem
    end

    private

    def carregar_restaurante
      @restaurante = Restaurant.find(params[:id])
    end

    def restaurante_params
      params.require(:restaurant).permit(:name, :localizacao, :capacidade, :horario_abertura, :horario_fechamento)
    end
  end
end
