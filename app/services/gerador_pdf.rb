# frozen_string_literal: true

# gerador minimo de pdf em ruby puro so com texto em helvetica
class GeradorPdf
  LINHAS_POR_PAGINA = 48
  MARGEM = 40
  TOPO = 800
  CABECALHO = "%PDF-1.4\n".b.freeze

  # gera o pdf de uma lista de linhas de texto
  # args: linhas (Array de String) com uma linha de texto por item
  # retorna: String binaria com o pdf, e uma pagina em branco quando a lista vem vazia
  # efeito: nenhum, nao grava arquivo
  def self.gerar(linhas:)
    new(linhas).call
  end

  # guarda as linhas do documento
  # args: linhas (Array de String), vazia vira uma linha em branco
  # retorna: a instancia
  # efeito: nenhum
  def initialize(linhas)
    @linhas = linhas.presence || ['']
  end

  # monta o documento inteiro
  # args: nenhum
  # retorna: String binaria com o pdf, 48 linhas por pagina
  # efeito: nenhum
  def call
    paginas = @linhas.each_slice(LINHAS_POR_PAGINA).to_a
    por_pagina = paginas.each_with_index.flat_map { |linhas, indice| objetos_da_pagina(linhas, indice) }
    montar(objetos_fixos(paginas.size) + por_pagina)
  end

  private

  # objetos 1 a 3 sao catalogo arvore de paginas e fonte depois vem pagina e conteudo de cada folha
  # args: total (Integer) de paginas
  # retorna: lista com os tres objetos fixos do pdf
  # efeito: nenhum
  def objetos_fixos(total)
    filhas = Array.new(total) { |indice| "#{4 + (2 * indice)} 0 R" }.join(' ')
    ['<< /Type /Catalog /Pages 2 0 R >>',
     "<< /Type /Pages /Kids [#{filhas}] /Count #{total} >>",
     '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>']
  end

  # pagina e conteudo de uma folha
  # args: linhas (Array de String) da folha e indice (Integer) dela, a partir de zero
  # retorna: lista com o objeto pagina e o objeto conteudo
  # efeito: nenhum
  def objetos_da_pagina(linhas, indice)
    ['<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 3 0 R >> >> ' \
     "/Contents #{5 + (2 * indice)} 0 R >>",
     conteudo(linhas)]
  end

  # texto de uma folha, uma linha por Tj
  # args: linhas (Array de String)
  # retorna: String binaria com o fluxo do conteudo e o tamanho dele
  # efeito: nenhum
  def conteudo(linhas)
    texto = linhas.map { |linha| "(#{escapar(linha)}) Tj T*" }.join("\n")
    fluxo = "BT /F1 10 Tf #{MARGEM} #{TOPO} Td 14 TL\n#{texto}\nET".b
    "<< /Length #{fluxo.bytesize} >>\nstream\n#{fluxo}\nendstream".b
  end

  # helvetica winansi entende acentos em windows 1252 e o resto vira interrogacao
  # args: linha (String ou nil)
  # retorna: String binaria com parenteses e barra escapados
  # efeito: nenhum
  def escapar(linha)
    linha.to_s.gsub(/[\\()]/) { |caractere| "\\#{caractere}" }
         .encode('Windows-1252', invalid: :replace, undef: :replace, replace: '?').b
  end

  # junta os objetos numerados e a tabela de posicoes, que e a soma dos tamanhos de tudo que veio antes
  # args: objetos (Array de String) na ordem do numero
  # retorna: String binaria com o pdf completo
  # efeito: nenhum
  def montar(objetos)
    pdf = CABECALHO.dup
    posicoes = objetos.each_with_index.map do |objeto, indice|
      posicao = pdf.bytesize
      pdf << numerar(indice + 1, objeto)
      posicao
    end
    pdf << rodape(posicoes, pdf.bytesize)
  end

  # envolve o conteudo com o numero do objeto e as marcas de inicio e fim
  # args: numero (Integer) do objeto e objeto (String) com o conteudo
  # retorna: String binaria do objeto completo
  # efeito: nenhum
  def numerar(numero, objeto)
    "#{numero} 0 obj\n".b << objeto.b << "\nendobj\n".b
  end

  # cada entrada da tabela xref tem 20 bytes
  # args: posicoes (Array de Integer) onde cada objeto comeca e inicio_da_tabela (Integer) onde a tabela comeca
  # retorna: String binaria com a tabela xref, o trailer e o fim do arquivo
  # efeito: nenhum
  def rodape(posicoes, inicio_da_tabela)
    tabela = posicoes.map { |posicao| format("%010d 00000 n \n", posicao) }.join
    "xref\n0 #{posicoes.size + 1}\n0000000000 65535 f \n#{tabela}" \
    "trailer\n<< /Size #{posicoes.size + 1} /Root 1 0 R >>\nstartxref\n#{inicio_da_tabela}\n%%EOF\n".b
  end
end
