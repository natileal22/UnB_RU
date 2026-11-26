# frozen_string_literal: true

# exportacao em pdf do relatorio global da issue 12 com periodo obrigatorio e filtros opcionais
class ExportacaoRelatorio
  MSG_SEM_REGISTROS = 'Não há registros no período para exportar'
  MSG_FILTRO_SEM_REGISTROS = 'Nenhum registro encontrado para os filtros informados'
  MSG_FALHA = 'Não foi possível gerar o PDF. Tente novamente'

  # resultado da exportacao, com o pdf e o nome do arquivo ou com o erro e o status da resposta
  Resultado = Struct.new(:pdf, :arquivo, :erro, :status, keyword_init: true) do
    # resultado de erro, sem pdf
    # args: erro (String) com a mensagem e status (Symbol) da resposta, 422 por padrao
    # retorna: Resultado com o erro e o status
    # efeito: nenhum
    def self.recusado(erro, status = :unprocessable_content)
      new(erro: erro, status: status)
    end

    # diz se a exportacao deu certo
    # args: nenhum
    # retorna: true quando nao ha erro
    # efeito: nenhum
    def sucesso?
      erro.blank?
    end
  end

  # uma linha da tabela com os dados do acesso
  # args: acesso (Access)
  # retorna: texto com data, restaurante, catraca, matricula e resultado
  # efeito: nenhum
  def self.linha(acesso)
    [I18n.l(acesso.occurred_at, format: '%d/%m/%Y %H:%M'), acesso.restaurant.name, acesso.catraca,
     acesso.matricula, acesso.resultado].join(' | ')
  end

  # prepara a exportacao com o periodo e os filtros do relatorio
  # args: data_inicial e data_final (String dd/mm/aaaa) e restaurant_id e catraca (String), os filtros sao opcionais
  # retorna: a instancia, com o periodo ja convertido e validado
  # efeito: nenhum
  def initialize(data_inicial: nil, data_final: nil, restaurant_id: nil, catraca: nil)
    @periodo = PeriodoFiltro.new(data_inicial: data_inicial, data_final: data_final, obrigatorio: true).call
    @filtros = { restaurant_id: restaurant_id.to_s.strip.presence, catraca: catraca.to_s.strip.presence }.compact
  end

  # gera o pdf do periodo
  # args: nenhum
  # retorna: Resultado com pdf e nome do arquivo, ou com erro e status 422 para periodo invalido e lista vazia,
  #          ou erro e status 500 quando a geracao falha
  # efeito: le o banco e registra no log quando a geracao falha, nao grava nada
  def call
    return Resultado.recusado(@periodo.erro) unless @periodo.valido?

    acessos = buscar
    return Resultado.recusado(motivo_sem_registros) if acessos.empty?

    gerar(acessos)
  end

  private

  # mesmos filtros de restaurante e catraca do relatorio global
  # args: nenhum
  # retorna: lista de Access do periodo, do mais recente para o mais antigo
  # efeito: so le o banco
  def buscar
    @periodo.aplicar(Access.includes(:restaurant).recent_first, :occurred_at).where(@filtros).to_a
  end

  # mensagem propria so quando o periodo tem registros e o filtro de restaurante ou catraca nao achou nenhum
  # args: nenhum
  # retorna: a mensagem de periodo sem registros ou a de filtro sem registros
  # efeito: so le o banco
  def motivo_sem_registros
    return MSG_SEM_REGISTROS if @filtros.empty? || !@periodo.aplicar(Access, :occurred_at).exists?

    MSG_FILTRO_SEM_REGISTROS
  end

  # monta as linhas e gera o pdf
  # args: acessos (Array de Access) do periodo
  # retorna: Resultado com o pdf, ou com erro e status 500 se algo falhar na geracao
  # efeito: registra a falha no log
  def gerar(acessos)
    Resultado.new(pdf: GeradorPdf.gerar(linhas: linhas(acessos)), arquivo: nome_do_arquivo)
  rescue StandardError => erro # rubocop:disable Naming/RescuedExceptionsVariableName -- nome claro
    Rails.logger.error("falha ao gerar o pdf do relatorio: #{erro.class} #{erro.message}")
    Resultado.recusado(MSG_FALHA, :internal_server_error)
  end

  # a catraca entra no nome so quando filtrada e sem caractere que nao seja letra numero hifen ou sublinhado
  # args: nenhum
  # retorna: nome do arquivo (String) com o periodo e, se houver, a catraca
  # efeito: nenhum
  def nome_do_arquivo
    catraca = @filtros[:catraca]&.gsub(/[^A-Za-z0-9_-]/, '_')&.first(30)
    datas = "#{@periodo.inicio.iso8601}_a_#{@periodo.fim.iso8601}"
    "#{['relatorio_operacao', catraca, datas].compact.join('_')}.pdf"
  end

  # todas as linhas do relatorio, o cabecalho e uma linha por acesso
  # args: acessos (Array de Access)
  # retorna: lista de linhas de texto
  # efeito: nenhum
  def linhas(acessos)
    cabecalho(acessos) + acessos.map { |acesso| self.class.linha(acesso) }
  end

  # titulo, periodo, filtros, totais e cabecalho da tabela
  # args: acessos (Array de Access)
  # retorna: lista de linhas de texto
  # efeito: nenhum
  def cabecalho(acessos)
    total = acessos.size
    liberados = acessos.count { |acesso| acesso.resultado == 'LIBERADO' }
    ['Relatório Global de Operação',
     "Período: #{@periodo.inicio.strftime('%d/%m/%Y')} a #{@periodo.fim.strftime('%d/%m/%Y')}",
     *filtros_aplicados(acessos),
     "Total de acessos: #{total} | Liberados: #{liberados} | Negados: #{total - liberados}",
     '',
     'Data e hora | Restaurante | Catraca | Matrícula | Resultado']
  end

  # uma linha para cada filtro que foi usado
  # args: acessos (Array de Access), o primeiro da o nome do restaurante
  # retorna: lista de linhas, vazia quando nao ha filtro
  # efeito: nenhum
  def filtros_aplicados(acessos)
    catraca = @filtros[:catraca]
    [("Restaurante: #{acessos.first.restaurant.name}" if @filtros[:restaurant_id]),
     ("Catraca: #{catraca}" if catraca)].compact
  end
end
