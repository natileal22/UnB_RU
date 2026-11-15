# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RelatorioPdfHelper, type: :helper do
  it 'converte aaaa-mm-dd para dd/mm/aaaa' do
    expect(helper.data_br('2026-09-01')).to eq('01/09/2026')
  end

  it 'devolve o valor como veio quando não é uma data' do
    expect(helper.data_br('abc')).to eq('abc')
    expect(helper.data_br(nil)).to be_nil
  end
end
