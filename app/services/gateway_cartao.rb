# frozen_string_literal: true

# Simula a operadora do cartão de crédito usada na recarga de saldo.
#
# Não há integração com banco real. Os cartões listados em
# +CARTOES_SEM_LIMITE+ sempre são recusados, para permitir testar o caminho triste.
class GatewayCartao
  # Números de cartão que a operadora simulada sempre recusa por falta de limite.
  CARTOES_SEM_LIMITE = %w[4000000000000002].freeze

  # Confere se os dados do cartão estão completos e no formato certo (RN04).
  #
  # Argumentos::
  #   +dados+ - +Hash+ com as chaves:
  #   - +:numero+ - 16 dígitos, espaços são ignorados;
  #   - +:nome+ - nome impresso, não pode ficar em branco;
  #   - +:validade+ - no formato MM/AA;
  #   - +:cvv+ - 3 dígitos.
  # Retorno::
  #   +true+ se os quatro campos são válidos; +false+ se algum estiver ausente
  #   ou fora do formato.
  # Efeitos colaterais:: nenhum.
  def self.dados_validos?(dados)
    numero, nome, validade, cvv = dados.values_at(:numero, :nome, :validade, :cvv)
    numero_valido?(numero) && nome.to_s.strip.present? && validade_valida?(validade) && cvv_valido?(cvv)
  end

  # Simula a resposta da operadora para uma compra.
  #
  # Argumentos::
  #   +numero+ - número do cartão (espaços são ignorados).
  # Retorno::
  #   +true+ se a compra foi autorizada; +false+ se o cartão está em
  #   +CARTOES_SEM_LIMITE+ (compra recusada por falta de limite).
  # Efeitos colaterais:: nenhum.
  def self.autorizar(numero:)
    CARTOES_SEM_LIMITE.exclude?(somente_digitos(numero))
  end

  # Confere se o número do cartão tem exatamente 16 dígitos.
  #
  # Argumentos::
  #   +numero+ - número do cartão, com ou sem espaços.
  # Retorno:: +true+ se tiver 16 dígitos; +false+ caso contrário (inclusive +nil+).
  # Efeitos colaterais:: nenhum.
  def self.numero_valido?(numero)
    somente_digitos(numero).match?(/\A\d{16}\z/)
  end

  # Confere se a validade está no formato MM/AA, com mês de 01 a 12.
  #
  # Argumentos::
  #   +validade+ - texto digitado, por exemplo "12/30".
  # Retorno:: +true+ se estiver no formato; +false+ caso contrário (inclusive +nil+).
  # Efeitos colaterais:: nenhum.
  def self.validade_valida?(validade)
    validade.to_s.match?(%r{\A(0[1-9]|1[0-2])/\d{2}\z})
  end

  # Confere se o CVV tem exatamente 3 dígitos.
  #
  # Argumentos::
  #   +cvv+ - código de segurança digitado.
  # Retorno:: +true+ se tiver 3 dígitos; +false+ caso contrário (inclusive +nil+).
  # Efeitos colaterais:: nenhum.
  def self.cvv_valido?(cvv)
    cvv.to_s.match?(/\A\d{3}\z/)
  end

  # Remove os espaços do número do cartão.
  #
  # Argumentos::
  #   +numero+ - número do cartão; pode ser +nil+.
  # Retorno:: +String+ sem espaços ("" quando +numero+ é +nil+).
  # Efeitos colaterais:: nenhum.
  def self.somente_digitos(numero)
    numero.to_s.gsub(/\s/, '')
  end
  private_class_method :numero_valido?, :validade_valida?, :cvv_valido?, :somente_digitos
end
