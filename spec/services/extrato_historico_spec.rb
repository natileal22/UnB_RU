# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength -- um describe por service com todos os casos
require 'rails_helper'

RSpec.describe ExtratoHistorico do
  let(:restaurante) { Restaurant.create!(name: 'RU Central') }
  let(:ana) { User.create!(name: 'Ana', matricula: '241000001', password: 'SenhaForte123', perfil: 'estudante') }
  let(:bruno) { User.create!(name: 'Bruno', matricula: '241000002', password: 'SenhaForte123', perfil: 'estudante') }

  def recarga(usuario, instante, status: 'aprovada')
    Recarga.create!(user: usuario, valor: 10, metodo: 'pix', status: status, created_at: Time.zone.parse(instante))
  end

  def acesso(usuario, instante, resultado: 'LIBERADO')
    Access.create!(restaurant: restaurante, catraca: 'CAT-01', matricula: usuario.matricula, user: usuario,
                   resultado: resultado, occurred_at: Time.zone.parse(instante))
  end

  def chamar(usuario = ana, **filtro)
    described_class.new(usuario: usuario, **filtro).call
  end

  it 'lista só as recargas do próprio estudante, da mais recente para a mais antiga' do
    antiga = recarga(ana, '2026-09-01 12:00')
    recente = recarga(ana, '2026-09-30 12:00')
    recarga(bruno, '2026-09-15 12:00')

    expect(chamar.recargas).to eq([recente, antiga])
  end

  it 'lista recargas de todos os status' do
    criadas = %w[pendente aprovada recusada].map { |status| recarga(ana, '2026-09-10 12:00', status: status) }

    expect(chamar.recargas).to match_array(criadas)
  end

  it 'desempata recargas do mesmo instante pelo id decrescente' do
    primeira = recarga(ana, '2026-09-10 12:00')
    segunda = recarga(ana, '2026-09-10 12:00')

    expect(chamar.recargas).to eq([segunda, primeira])
  end

  it 'lista só as refeições liberadas do próprio estudante, da mais recente para a mais antiga' do
    antiga = acesso(ana, '2026-09-10 11:45')
    recente = acesso(ana, '2026-09-11 12:10')
    acesso(ana, '2026-09-11 12:20', resultado: 'NEGADO')
    acesso(bruno, '2026-09-12 12:30')

    expect(chamar.refeicoes).to eq([recente, antiga])
  end

  it 'não usa acesso só com a matrícula e sem usuário ligado' do
    Access.create!(restaurant: restaurante, catraca: 'CAT-01', matricula: ana.matricula, resultado: 'LIBERADO',
                   occurred_at: Time.zone.parse('2026-09-10 12:00'))

    expect(chamar.refeicoes).to be_empty
  end

  it 'filtra as duas listas pelo período incluindo os dias limites' do
    dentro = recarga(ana, '2026-09-30 23:59:59')
    recarga(ana, '2026-08-31 23:59:59')
    refeicao = acesso(ana, '2026-09-01 00:00:00')
    acesso(ana, '2026-10-01 00:00:00')

    resultado = chamar(data_inicial: '01/09/2026', data_final: '30/09/2026')

    expect(resultado.recargas).to eq([dentro])
    expect(resultado.refeicoes).to eq([refeicao])
  end

  it 'devolve listas vazias e o erro quando o período é inválido' do
    recarga(ana, '2026-09-10 12:00')

    resultado = chamar(data_inicial: '30/09/2026', data_final: '01/09/2026')

    expect(resultado).not_to be_valido
    expect(resultado.erro).to eq(PeriodoFiltro::MSG_PERIODO_INVERTIDO)
    expect([resultado.recargas, resultado.refeicoes]).to eq([[], []])
  end

  it 'devolve listas vazias sem expor registros de outro estudante' do
    recarga(bruno, '2026-09-10 12:00')
    acesso(bruno, '2026-09-10 12:00')

    resultado = chamar

    expect(resultado).to be_valido
    expect([resultado.recargas, resultado.refeicoes]).to eq([[], []])
  end
end
# rubocop:enable Metrics/BlockLength
