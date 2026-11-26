# frozen_string_literal: true

module Admin
  # exportacao em pdf do relatorio global da issue 12 so para administrador
  class ExportacoesController < ApplicationController
    layout 'administracao'

    before_action :exigir_login
    before_action :exigir_administrador

    # exporta o relatorio global de operacao em pdf
    # args: nenhum, o periodo e os filtros vem de params
    # retorna: envia o pdf como anexo ou mostra a pagina de erro com o status do ExportacaoRelatorio
    # efeito: le o banco e envia um arquivo, nao grava nada
    def show
      resultado = ExportacaoRelatorio.new(**parametros).call
      return mostrar_erro(resultado.erro, resultado.status) unless resultado.sucesso?

      send_data resultado.pdf, filename: resultado.arquivo, type: 'application/pdf', disposition: 'attachment'
    end

    private

    # periodo obrigatorio e os mesmos filtros de restaurante e catraca do relatorio
    # args: nenhum, os dados vem de params
    # retorna: hash com as datas, o restaurante e a catraca em simbolos
    # efeito: nenhum
    def parametros
      params.permit(:data_inicial, :data_final, :restaurant_id, :catraca).to_h.symbolize_keys
    end

    # barra quem nao e administrador
    # args: nenhum
    # retorna: segue para o administrador, senao mostra o erro com status 403
    # efeito: renderiza no layout application e interrompe a acao
    def exigir_administrador
      return if current_user.perfil == 'administrador'

      # o cabecalho da administracao nao serve para quem nao e administrador
      mostrar_erro('Acesso negado: apenas o Administrador pode exportar o relatório', :forbidden, 'application')
    end

    # mostra a pagina de erro da exportacao
    # args: mensagem (String), status (Symbol) e layout (String), administracao por padrao
    # retorna: renderiza erro com a mensagem e o status
    # efeito: nenhum no banco
    def mostrar_erro(mensagem, status, layout = 'administracao')
      @mensagem = mensagem
      render :erro, status: status, layout: layout
    end
  end
end
