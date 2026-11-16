# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
require 'rails_helper'

RSpec.describe GeradorPdf do
  def gerar(linhas)
    described_class.gerar(linhas: linhas)
  end

  it 'começa com o cabeçalho e termina com o marcador de fim' do
    pdf = gerar(['Linha um'])

    expect(pdf).to start_with('%PDF-1.4')
    expect(pdf).to end_with("%%EOF\n")
    expect(pdf.encoding).to eq(Encoding::BINARY)
  end

  it 'aponta a tabela xref e cada objeto para o byte certo' do
    pdf = gerar(Array.new(60) { |indice| "Linha #{indice}" })
    inicio = pdf[/startxref\n(\d+)\n%%EOF/, 1].to_i
    posicoes = pdf.byteslice(inicio..).scan(/^(\d{10}) 00000 n $/).flatten.map(&:to_i)

    expect(pdf.byteslice(inicio, 4)).to eq('xref')
    expect(posicoes.size).to eq(pdf[%r{/Size (\d+)}, 1].to_i - 1)
    posicoes.each_with_index do |posicao, indice|
      expect(pdf.byteslice(posicao, "#{indice + 1} 0 obj".size)).to eq("#{indice + 1} 0 obj")
    end
  end

  it 'quebra em uma nova página a cada 48 linhas' do
    expect(gerar(Array.new(48, 'a'))).to include('/Count 1')
    expect(gerar(Array.new(49, 'a'))).to include('/Count 2')
    expect(gerar(Array.new(97, 'a'))).to include('/Count 3')
  end

  it 'escapa parênteses e barra e converte acentos para windows 1252' do
    pdf = gerar(['Relatório (teste) \\'])
    esperado = "(Relat#{[0xF3].pack('C')}rio \\(teste\\) \\\\) Tj".b

    expect(pdf).to include(esperado)
  end

  it 'troca o caractere que a fonte não tem por interrogação' do
    expect(gerar(['Olá ✓'])).to include("Ol#{[0xE1].pack('C')} ?".b)
  end

  it 'gera um pdf de uma página mesmo sem linhas' do
    expect(gerar([])).to include('/Count 1')
  end
end
# rubocop:enable Metrics/BlockLength
