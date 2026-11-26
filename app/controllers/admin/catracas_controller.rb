# frozen_string_literal: true

module Admin
  # catracas da gestao de restaurantes so para administrador
  class CatracasController < ApplicationController
    include GestaoAdministrativa

    before_action :carregar_catraca, only: %i[edit update destroy]

    # abre a tela de gestao com o formulario de edicao da catraca
    # args: nenhum, o id vem de params
    # retorna: renderiza a listagem com status 200
    # efeito: so le o banco
    def edit
      @catraca_em_edicao = @catraca
      renderizar_gestao
    end

    # cadastra uma catraca
    # args: nenhum, os dados vem de params
    # retorna: redireciona para a listagem com sucesso ou mostra o erro com status 422
    # efeito: grava uma Catraca no banco quando valida
    def create
      @nova_catraca = Catraca.new(catraca_params)
      salvar(@nova_catraca, 'Catraca cadastrada com sucesso')
    end

    # atualiza os dados de uma catraca
    # args: nenhum, o id e os dados vem de params
    # retorna: redireciona para a listagem com sucesso ou mostra o erro com o formulario de edicao e status 422
    # efeito: altera a Catraca no banco quando valida
    def update
      @catraca.assign_attributes(catraca_params)
      @catraca_em_edicao = @catraca
      salvar(@catraca, 'Catraca atualizada com sucesso')
    end

    # remove uma catraca inativa, sem responsavel e sem acessos
    # args: nenhum, o id vem de params
    # retorna: redireciona para a listagem com sucesso ou com o motivo do bloqueio
    # efeito: apaga a Catraca do banco quando permitido
    def destroy
      remover(@catraca, 'Catraca removida com sucesso')
    end

    private

    # acha a catraca da acao
    # args: nenhum, o id vem de params
    # retorna: define @catraca ou lanca RecordNotFound para um id que nao existe
    # efeito: so le o banco
    def carregar_catraca
      @catraca = Catraca.find(params[:id])
    end

    # libera so os campos que a gestao pode alterar
    # args: nenhum, os dados vem de params
    # retorna: ActionController::Parameters permitido
    # efeito: lanca ParameterMissing quando falta o grupo catraca
    def catraca_params
      params.require(:catraca).permit(:codigo, :restaurant_id, :status, :responsavel_id,
                                      :horario_abertura, :horario_fechamento)
    end
  end
end
