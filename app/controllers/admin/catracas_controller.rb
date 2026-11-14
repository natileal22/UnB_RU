# frozen_string_literal: true

module Admin
  # catracas da gestao de restaurantes so para administrador
  class CatracasController < ApplicationController
    include GestaoAdministrativa

    before_action :carregar_catraca, only: %i[edit update destroy]

    def new
      renderizar_gestao
    end

    def edit
      @catraca_em_edicao = @catraca
      renderizar_gestao
    end

    def create
      @nova_catraca = Catraca.new(catraca_params)
      return falha_de_validacao(@nova_catraca) unless @nova_catraca.save(context: :gestao)

      redirect_to admin_restaurantes_path, notice: 'Catraca cadastrada com sucesso'
    end

    def update
      @catraca.assign_attributes(catraca_params)
      if @catraca.save(context: :gestao)
        return redirect_to admin_restaurantes_path,
                           notice: 'Catraca atualizada com sucesso'
      end

      @catraca_em_edicao = @catraca
      falha_de_validacao(@catraca)
    end

    def destroy
      motivo = @catraca.motivo_bloqueio_remocao
      return redirect_to admin_restaurantes_path, alert: motivo if motivo

      @catraca.destroy!
      redirect_to admin_restaurantes_path, notice: 'Catraca removida com sucesso'
    end

    private

    def carregar_catraca
      @catraca = Catraca.find(params[:id])
    end

    def catraca_params
      params.require(:catraca).permit(:codigo, :restaurant_id, :status, :responsavel_id)
    end
  end
end
