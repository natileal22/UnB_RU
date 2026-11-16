# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
require 'rails_helper'

RSpec.describe ExportacaoRelatorio do
  let(:restaurante) { Restaurant.create!(name: 'RU Central') }

  def acesso(matricula, quando, resultado: 'LIBERADO')
    Access.create!(restaurant: restaurante, catraca: 'CAT-01', matricula: matricula, resultado: resultado,
                   occurred_at: Time.zone.parse(quando))
  end

  def exportar(inicial, final)
    described_class.new(data_inicial: inicial, data_final: final).call
  end

  it 'gera o pdf do período com o nome do arquivo em aaaa-mm-dd' do
    acesso('241000001', '2026-09-10 11:45')

    resultado = exportar('01/09/2026', '30/09/2026')

    expect(resultado).to be_sucesso
    expect(resultado.arquivo).to eq('relatorio_operacao_2026-09-01_a_2026-09-30.pdf')
    expect(resultado.pdf).to include('241000001', 'Total de acessos: 1')
  end

  it 'inclui o último dia inteiro e deixa de fora os dias vizinhos' do
    acesso('241000001', '2026-09-30 23:59')
    acesso('241000002', '2026-10-01 00:00')
    acesso('241000003', '2026-08-31 23:59')

    pdf = exportar('01/09/2026', '30/09/2026').pdf

    expect(pdf).to include('241000001')
    expect(pdf).not_to include('241000002', '241000003')
  end

  it 'lista do mais recente para o mais antigo e conta liberados e negados' do
    acesso('241000001', '2026-09-10 11:45')
    acesso('241000002', '2026-09-10 12:20', resultado: 'NEGADO')

    pdf = exportar('10/09/2026', '10/09/2026').pdf

    expect(pdf.index('241000002')).to be < pdf.index('241000001')
    expect(pdf).to include('Total de acessos: 2 | Liberados: 1 | Negados: 1')
  end

  describe 'filtros opcionais' do
    let(:gama) { Restaurant.create!(name: 'RU Gama') }

    before do
      acesso('241000001', '2026-09-10 11:45')
      Access.create!(restaurant: restaurante, catraca: 'CAT-02', matricula: '241000002', resultado: 'LIBERADO',
                     occurred_at: Time.zone.parse('2026-09-10 12:00'))
      Access.create!(restaurant: gama, catraca: 'CAT-01', matricula: '241000003', resultado: 'LIBERADO',
                     occurred_at: Time.zone.parse('2026-09-10 12:30'))
    end

    def exportar_com(**filtros)
      described_class.new(data_inicial: '01/09/2026', data_final: '30/09/2026', **filtros).call
    end

    it 'sem filtro traz todos os acessos e mantém o nome do arquivo' do
      resultado = exportar_com

      expect(resultado.pdf).to include('241000001', '241000002', '241000003')
      expect(resultado.arquivo).to eq('relatorio_operacao_2026-09-01_a_2026-09-30.pdf')
    end

    it 'filtra por catraca e põe a catraca no nome do arquivo' do
      resultado = exportar_com(catraca: 'CAT-02')

      expect(resultado.pdf).to include('241000002', 'Catraca: CAT-02')
      expect(resultado.pdf).not_to include('241000001', '241000003')
      expect(resultado.arquivo).to eq('relatorio_operacao_CAT-02_2026-09-01_a_2026-09-30.pdf')
    end

    it 'filtra por restaurante e escreve o restaurante no cabeçalho' do
      resultado = exportar_com(restaurant_id: gama.id)

      expect(resultado.pdf).to include('241000003', 'Restaurante: RU Gama')
      expect(resultado.pdf).not_to include('241000001', '241000002')
    end

    it 'combina restaurante e catraca' do
      resultado = exportar_com(restaurant_id: restaurante.id, catraca: 'CAT-01')

      expect(resultado.pdf).to include('241000001')
      expect(resultado.pdf).not_to include('241000002', '241000003')
    end

    it 'usa a mensagem do filtro quando o período tem registros e o filtro não acha nenhum' do
      resultado = exportar_com(catraca: 'CAT-99')

      expect(resultado.erro).to eq('Nenhum registro encontrado para os filtros informados')
      expect(resultado.status).to eq(:unprocessable_content)
      expect(exportar_com(restaurant_id: 999_999).erro).to eq('Nenhum registro encontrado para os filtros informados')
    end

    it 'mantém a mensagem do período quando o período está vazio mesmo com filtro' do
      resultado = described_class.new(data_inicial: '01/01/2026', data_final: '31/01/2026', catraca: 'CAT-01').call

      expect(resultado.erro).to eq('Não há registros no período para exportar')
    end

    it 'mantém a mensagem do período quando não há filtro e o período está vazio' do
      resultado = described_class.new(data_inicial: '01/01/2026', data_final: '31/01/2026').call

      expect(resultado.erro).to eq('Não há registros no período para exportar')
    end
    it 'troca no nome do arquivo o que não é letra, número, hífen ou sublinhado' do
      Access.create!(restaurant: restaurante, catraca: '../CAT 7', matricula: '241000004', resultado: 'LIBERADO',
                     occurred_at: Time.zone.parse('2026-09-10 13:00'))

      arquivo = exportar_com(catraca: '../CAT 7').arquivo

      expect(arquivo).to eq('relatorio_operacao____CAT_7_2026-09-01_a_2026-09-30.pdf')
      expect(arquivo).not_to include('.._', '/')
    end
  end
  it 'recusa período sem registros' do
    resultado = exportar('01/09/2026', '30/09/2026')

    expect(resultado).not_to be_sucesso
    expect(resultado.erro).to eq('Não há registros no período para exportar')
    expect(resultado.status).to eq(:unprocessable_content)
  end

  [['30/09/2026', '01/09/2026', 'A data inicial não pode ser posterior à data final'],
   ['31/02/2026', '28/02/2026', 'Data inválida: use o formato dd/mm/aaaa'],
   ['01/09/2026', 'abc', 'Data inválida: use o formato dd/mm/aaaa'],
   ['', '30/09/2026', 'Data inválida: use o formato dd/mm/aaaa'],
   ['1/9/2026', '30/09/2026', 'Data inválida: use o formato dd/mm/aaaa']].each do |inicial, final, mensagem|
    it "recusa o período #{inicial.inspect} a #{final.inspect}" do
      resultado = exportar(inicial, final)

      expect(resultado.erro).to eq(mensagem)
      expect(resultado.pdf).to be_nil
    end
  end

  it 'devolve erro de geração quando o gerador falha' do
    acesso('241000001', '2026-09-10 11:45')
    allow(GeradorPdf).to receive(:gerar).and_raise(StandardError, 'falha')

    resultado = exportar('01/09/2026', '30/09/2026')

    expect(resultado.erro).to eq('Não foi possível gerar o PDF. Tente novamente')
    expect(resultado.status).to eq(:internal_server_error)
  end
end
# rubocop:enable Metrics/BlockLength
