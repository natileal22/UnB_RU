# frozen_string_literal: true

# gerador minimo de pdf em ruby puro so com texto em helvetica
class GeradorPdf
  LINHAS_POR_PAGINA = 48
  MARGEM = 40
  TOPO = 800

  def self.gerar(linhas:)
    new(linhas).call
  end

  def initialize(linhas)
    @linhas = linhas.presence || ['']
  end

  def call
    paginas = @linhas.each_slice(LINHAS_POR_PAGINA).to_a
    por_pagina = paginas.each_with_index.flat_map { |linhas, indice| objetos_da_pagina(linhas, indice) }
    montar(objetos_fixos(paginas.size) + por_pagina)
  end

  private

  # objetos 1 a 3 sao catalogo arvore de paginas e fonte depois vem pagina e conteudo de cada folha
  def objetos_fixos(total)
    filhas = Array.new(total) { |indice| "#{4 + (2 * indice)} 0 R" }.join(' ')
    ['<< /Type /Catalog /Pages 2 0 R >>',
     "<< /Type /Pages /Kids [#{filhas}] /Count #{total} >>",
     '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>']
  end

  def objetos_da_pagina(linhas, indice)
    ['<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 3 0 R >> >> ' \
     "/Contents #{5 + (2 * indice)} 0 R >>",
     conteudo(linhas)]
  end

  def conteudo(linhas)
    texto = linhas.map { |linha| "(#{escapar(linha)}) Tj T*" }.join("\n")
    fluxo = "BT /F1 10 Tf #{MARGEM} #{TOPO} Td 14 TL\n#{texto}\nET".b
    "<< /Length #{fluxo.bytesize} >>\nstream\n#{fluxo}\nendstream".b
  end

  # helvetica winansi entende acentos em windows 1252 e o resto vira interrogacao
  def escapar(linha)
    linha.to_s.gsub(/[\\()]/) { |caractere| "\\#{caractere}" }
         .encode('Windows-1252', invalid: :replace, undef: :replace, replace: '?').b
  end

  def montar(objetos)
    saida = "%PDF-1.4\n".b
    posicoes = objetos.each_with_index.map do |objeto, indice|
      posicao = saida.bytesize
      saida << "#{indice + 1} 0 obj\n".b << objeto.b << "\nendobj\n".b
      posicao
    end
    saida << rodape(posicoes, saida.bytesize)
  end

  # cada entrada da tabela xref tem 20 bytes
  def rodape(posicoes, inicio_da_tabela)
    tabela = posicoes.map { |posicao| format("%010d 00000 n \n", posicao) }.join
    "xref\n0 #{posicoes.size + 1}\n0000000000 65535 f \n#{tabela}" \
    "trailer\n<< /Size #{posicoes.size + 1} /Root 1 0 R >>\nstartxref\n#{inicio_da_tabela}\n%%EOF\n".b
  end
end
