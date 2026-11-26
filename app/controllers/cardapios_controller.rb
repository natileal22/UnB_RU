# frozen_string_literal: true

# Cardápio da refeição atual (página pública, RN07).
#
# Mostra o cardápio da refeição que está sendo servida agora ou, fora do
# horário de funcionamento, qual é a próxima refeição.
class CardapiosController < ApplicationController
  # Prepara a página do cardápio de acordo com o horário atual.
  #
  # Argumentos:: nenhum. Não exige login nem lê parâmetros.
  # Retorno::
  #   Nenhum valor útil; renderiza a tela +show+ em um destes casos:
  #   - Em horário de refeição com cardápio: +@refeicao+ e +@cardapio+ preenchidos (RN02).
  #   - Em horário de refeição sem cardápio: +@refeicao+ preenchido e +@cardapio+ +nil+,
  #     e a tela mostra "ainda não foi disponibilizado" (RN04).
  #   - Fora do horário: +@refeicao+ +nil+ e +@proxima+ com a próxima refeição (RN05).
  # Efeitos colaterais::
  #   Nenhum. Só consulta o banco, e só o cardápio da data de hoje (RN03).
  def show
    @refeicao = HorarioRefeicao.atual
    if @refeicao
      @cardapio = Cardapio.includes(:itens).find_by(data: Time.zone.today, refeicao: @refeicao.chave)
    else
      @proxima = HorarioRefeicao.proxima
    end
  end
end
