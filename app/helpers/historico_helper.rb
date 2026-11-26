# frozen_string_literal: true

# textos da tela do historico local da catraca
module HistoricoHelper
  # titulo da tela com o codigo das catracas
  # args: catracas (Array de Catraca)
  # retorna: texto no singular, no plural ou so Historico Local sem catraca
  # efeito: nenhum
  def titulo_historico(catracas)
    codigos = catracas.map(&:codigo).join(', ')
    return 'Histórico Local' if catracas.empty?

    catracas.one? ? "Histórico Local da Catraca #{codigos}" : "Histórico Local das Catracas #{codigos}"
  end

  # texto do selo de cada acesso
  # args: acesso (Access)
  # retorna: Liberado ou Recusado com o motivo
  # efeito: nenhum
  def status_do_acesso(acesso)
    return 'Liberado' if acesso.resultado == 'LIBERADO'

    "Recusado: #{ValidacaoEntrada::MENSAGENS.fetch(acesso.motivo_negacao, 'Acesso negado')}"
  end

  # opcoes do filtro de status
  # args: nenhum
  # retorna: lista de pares texto e valor para o select
  # efeito: nenhum
  def opcoes_de_status
    [['Todos os registros', ''], %w[Liberado LIBERADO], %w[Recusado NEGADO]]
  end
end
