# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
require 'rails_helper'

RSpec.describe HistoricoLocal do
  let(:restaurante) { Restaurant.create!(name: 'RU Central') }
  let(:funcionario) do
    User.create!(name: 'Func', matricula: '9000001', password: 'SenhaForte123', perfil: 'funcionario')
  end

  def acesso(codigo, matricula, data, resultado: 'LIBERADO', motivo: nil)
    Access.create!(restaurant: restaurante, catraca: codigo, matricula: matricula, resultado: resultado,
                   motivo_negacao: motivo, occurred_at: Time.zone.parse(data))
  end

  def chamar(**filtro)
    described_class.new(usuario: funcionario, **filtro).call
  end

  before do
    Catraca.create!(restaurant: restaurante, codigo: 'CAT-01', responsavel: funcionario)
    Catraca.create!(restaurant: restaurante, codigo: 'CAT-02')
  end

  it 'lista só os acessos das catracas vinculadas, do mais recente para o mais antigo' do
    antigo = acesso('CAT-01', '241000001', '2026-09-10 11:45')
    recente = acesso('CAT-01', '241000002', '2026-09-10 12:00', resultado: 'NEGADO', motivo: 'SALDO_INSUFICIENTE')
    acesso('CAT-02', '241000003', '2026-09-10 12:05')

    expect(chamar.acessos).to eq([recente, antigo])
  end

  it 'avisa quando não há catraca vinculada' do
    Catraca.update_all(responsavel_id: nil)

    resultado = chamar
    expect(resultado).to be_sem_catraca
    expect(resultado.acessos).to be_empty
  end

  it 'filtra pelo período inclusive nas datas das pontas' do
    dentro = acesso('CAT-01', '241000001', '2026-09-10 23:30')
    acesso('CAT-01', '241000002', '2026-09-11 00:10')
    acesso('CAT-01', '241000003', '2026-09-09 23:59')

    expect(chamar(data_inicial: '10/09/2026', data_final: '10/09/2026').acessos).to eq([dentro])
  end

  it 'aceita só um dos limites' do
    acesso('CAT-01', '241000001', '2026-09-01 10:00')
    novo = acesso('CAT-01', '241000002', '2026-09-20 10:00')

    expect(chamar(data_inicial: '10/09/2026').acessos).to eq([novo])
  end

  it 'rejeita data inicial posterior à final' do
    resultado = chamar(data_inicial: '30/09/2026', data_final: '01/09/2026')

    expect(resultado).not_to be_valido
    expect(resultado.mensagem).to eq('A data inicial não pode ser posterior à data final')
  end

  ['31/02/2026', 'abc', '2026-09-01', '1/9/2026'].each do |texto|
    it "rejeita a data #{texto.inspect} fora do formato dd/mm/aaaa" do
      resultado = chamar(data_inicial: texto, data_final: '28/02/2026')

      expect(resultado).not_to be_valido
      expect(resultado.mensagem).to eq('Data inválida: use o formato dd/mm/aaaa')
    end
  end
end
# rubocop:enable Metrics/BlockLength
