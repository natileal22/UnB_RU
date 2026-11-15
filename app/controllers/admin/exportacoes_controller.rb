# frozen_string_literal: true

module Admin
  # exportacao em pdf do relatorio global da issue 12 so para administrador
  class ExportacoesController < ApplicationController
    layout 'administracao'

    before_action :exigir_login
    before_action :exigir_administrador

    def show
      resultado = ExportacaoRelatorio.new(**parametros).call
      return mostrar_erro(resultado.erro, resultado.status) unless resultado.sucesso?

      send_data resultado.pdf, filename: resultado.arquivo, type: 'application/pdf', disposition: 'attachment'
    end

    private

    # periodo obrigatorio e os mesmos filtros de restaurante e catraca do relatorio
    def parametros
      params.permit(:data_inicial, :data_final, :restaurant_id, :catraca).to_h.symbolize_keys
    end

    def exigir_administrador
      return if current_user.perfil == 'administrador'

      # o cabecalho da administracao nao serve para quem nao e administrador
      mostrar_erro('Acesso negado: apenas o Administrador pode exportar o relatório', :forbidden, 'application')
    end

    def mostrar_erro(mensagem, status, layout = 'administracao')
      @mensagem = mensagem
      render :erro, status: status, layout: layout
    end
  end
end
