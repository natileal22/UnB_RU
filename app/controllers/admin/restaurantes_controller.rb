# frozen_string_literal: true

module Admin
  # gestao de restaurantes e catracas da issue 8 so para administrador
  class RestaurantesController < ApplicationController
    include GestaoAdministrativa

    before_action :carregar_restaurante, only: %i[edit update destroy ativar inativar]

    # abre a tela de gestao com o formulario de edicao do restaurante
    # args: nenhum, o id vem de params
    # retorna: renderiza a listagem com status 200
    # efeito: so le o banco
    def edit
      @restaurante_em_edicao = @restaurante
      renderizar_gestao
    end

    # cadastra um restaurante
    # args: nenhum, os dados vem de params
    # retorna: redireciona para a listagem com sucesso ou mostra o erro com status 422
    # efeito: grava um Restaurant no banco quando valido
    def create
      @novo_restaurante = Restaurant.new(restaurante_params)
      salvar(@novo_restaurante, 'Restaurante cadastrado com sucesso')
    end

    # atualiza os dados de um restaurante
    # args: nenhum, o id e os dados vem de params
    # retorna: redireciona para a listagem com sucesso ou mostra o erro com o formulario de edicao e status 422
    # efeito: altera o Restaurant no banco quando valido
    def update
      @restaurante.assign_attributes(restaurante_params)
      @restaurante_em_edicao = @restaurante
      salvar(@restaurante, 'Restaurante atualizado com sucesso')
    end

    # remove um restaurante sem catracas nem acessos
    # args: nenhum, o id vem de params
    # retorna: redireciona para a listagem com sucesso ou com o motivo do bloqueio
    # efeito: apaga o Restaurant do banco quando permitido
    def destroy
      remover(@restaurante, 'Restaurante removido com sucesso')
    end

    # reativa um restaurante inativo
    # args: nenhum, o id vem de params
    # retorna: redireciona para a listagem com a mensagem de sucesso
    # efeito: grava o status ativo no banco
    def ativar
      @restaurante.update!(status: 'ativo')
      redirect_to admin_restaurantes_path, notice: 'Restaurante ativado com sucesso'
    end

    # inativa um restaurante e as catracas ativas dele
    # args: nenhum, o id vem de params
    # retorna: redireciona para a listagem com a mensagem do InativacaoRestaurante
    # efeito: grava o status inativo no restaurante e nas catracas ativas
    def inativar
      resultado = InativacaoRestaurante.new(restaurante: @restaurante).call
      redirect_to admin_restaurantes_path, notice: resultado.mensagem
    end

    private

    # acha o restaurante da acao
    # args: nenhum, o id vem de params
    # retorna: define @restaurante ou lanca RecordNotFound para um id que nao existe
    # efeito: so le o banco
    def carregar_restaurante
      @restaurante = Restaurant.find(params[:id])
    end

    # libera so os campos que a gestao pode alterar
    # args: nenhum, os dados vem de params
    # retorna: ActionController::Parameters permitido
    # efeito: lanca ParameterMissing quando falta o grupo restaurant
    def restaurante_params
      params.require(:restaurant).permit(:name, :localizacao, :capacidade, :horario_abertura, :horario_fechamento)
    end
  end
end
