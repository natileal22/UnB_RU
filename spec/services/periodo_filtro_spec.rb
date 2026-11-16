# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength -- um describe por service com todos os casos
require 'rails_helper'

RSpec.describe PeriodoFiltro do
  def chamar(inicial = nil, final = nil)
    described_class.new(data_inicial: inicial, data_final: final).call
  end

  it 'aceita o período vazio como sem limite' do
    resultado = chamar

    expect(resultado).to be_valido
    expect([resultado.inicio, resultado.fim]).to eq([nil, nil])
  end

  it 'aceita só uma das datas' do
    expect(chamar('01/09/2026').fim).to be_nil
    expect(chamar(nil, '30/09/2026').inicio).to be_nil
  end

  it 'recusa formato inválido e data inexistente' do
    %w[abc 2026-09-01 1/9/2026 31/02/2026].each do |texto|
      expect(chamar(texto, '30/09/2026').erro).to eq(PeriodoFiltro::MSG_DATA_INVALIDA)
    end
  end

  it 'recusa período invertido' do
    expect(chamar('30/09/2026', '01/09/2026').erro).to eq(PeriodoFiltro::MSG_PERIODO_INVERTIDO)
  end

  it 'aceita o mesmo dia nos dois extremos' do
    expect(chamar('10/09/2026', '10/09/2026')).to be_valido
  end

  describe '#aplicar' do
    let(:usuario) { User.create!(name: 'Ana', matricula: '241000001', password: 'SenhaForte123', perfil: 'estudante') }

    def recarga(instante)
      Recarga.create!(user: usuario, valor: 10, metodo: 'pix', status: 'aprovada',
                      created_at: Time.zone.parse(instante))
    end

    it 'inclui os dois dias limites do primeiro ao último segundo' do
      fora_antes = recarga('2026-08-31 23:59:59')
      dentro = [recarga('2026-09-01 00:00:00'), recarga('2026-09-30 23:59:59')]
      fora_depois = recarga('2026-10-01 00:00:00')

      encontradas = chamar('01/09/2026', '30/09/2026').aplicar(Recarga.all, :created_at)

      expect(encontradas).to match_array(dentro)
      expect(encontradas).not_to include(fora_antes, fora_depois)
    end

    it 'não limita quando o período é vazio' do
      criada = recarga('2026-01-01 10:00')

      expect(chamar.aplicar(Recarga.all, :created_at)).to include(criada)
    end
  end
end
# rubocop:enable Metrics/BlockLength
