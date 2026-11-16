# frozen_string_literal: true

# textos da tela do historico local da catraca
module HistoricoHelper
  def titulo_historico(catracas)
    codigos = catracas.map(&:codigo).join(', ')
    return 'Histórico Local' if catracas.empty?

    catracas.one? ? "Histórico Local da Catraca #{codigos}" : "Histórico Local das Catracas #{codigos}"
  end

  # texto do selo de cada acesso
  def status_do_acesso(acesso)
    return 'Liberado' if acesso.resultado == 'LIBERADO'

    "Recusado: #{ValidacaoEntrada::MENSAGENS.fetch(acesso.motivo_negacao, 'Acesso negado')}"
  end

  def opcoes_de_status
    [['Todos os registros', ''], %w[Liberado LIBERADO], %w[Recusado NEGADO]]
  end
end
