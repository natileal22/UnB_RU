# Simula a operadora do cartão de crédito.
# Cartões listados em CARTOES_SEM_LIMITE sempre são recusados, para assim poder fazer o caminho triste.
class GatewayCartao
  CARTOES_SEM_LIMITE = %w[4000000000000002].freeze

  def self.dados_validos?(numero:, nome:, validade:, cvv:)
    numero.to_s.gsub(/\s/, '').match?(/\A\d{16}\z/) &&
      nome.to_s.strip.present? &&
      validade.to_s.match?(%r{\A(0[1-9]|1[0-2])/\d{2}\z}) &&
      cvv.to_s.match?(/\A\d{3}\z/)
  end

  def self.autorizar(numero:)
    CARTOES_SEM_LIMITE.exclude?(numero.to_s.gsub(/\s/, ''))
  end
end