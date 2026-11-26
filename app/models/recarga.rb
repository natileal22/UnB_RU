# frozen_string_literal: true

# Recarga de saldo feita por um estudante, por PIX ou cartão de crédito.
#
# Toda recarga nasce +pendente+ e termina +aprovada+ (o valor entra no saldo)
# ou +recusada+ (o saldo não muda). Uma recarga nunca é creditada duas vezes.
class Recarga < ApplicationRecord
  belongs_to :user

  # A validação do valor vem antes do enum para que a mensagem dela apareça primeiro.
  validates :valor, numericality: { greater_than: 0, message: 'de recarga inválido' }

  enum :metodo, { pix: 'pix', cartao_credito: 'cartao_credito' }, validate: true
  enum :status, { pendente: 'pendente', aprovada: 'aprovada', recusada: 'recusada' }

  # Aprova uma recarga pendente e credita o +valor+ no saldo do estudante.
  #
  # Argumentos:: nenhum. Usa os dados da própria recarga (+valor+ e +user+).
  # Retorno::
  #   - +true+ quando a recarga é aprovada e o saldo é creditado.
  #   - Lança +RuntimeError+ ("Recarga já processada") se a recarga não
  #     estiver +pendente+, o que impede creditar a mesma recarga duas vezes.
  # Efeitos colaterais::
  #   Altera o banco de dados: muda o +status+ da recarga para +aprovada+ e
  #   soma o +valor+ ao +saldo+ do usuário. As duas mudanças acontecem na mesma
  #   transação: ou as duas são gravadas, ou nenhuma.
  def aprovar!
    raise 'Recarga já processada' unless pendente?

    transaction do
      aprovada!
      user.increment!(:saldo, valor)
    end
  end

  # Marca a recarga como recusada (por exemplo, cartão sem limite).
  #
  # Argumentos:: nenhum.
  # Retorno::
  #   +true+ se o status foi gravado. Lança +ActiveRecord::RecordInvalid+ se
  #   a recarga não puder ser salva.
  # Efeitos colaterais::
  #   Altera o banco de dados: muda o +status+ da recarga para +recusada+.
  #   Diferente de +aprovar!+, *não* mexe no saldo do estudante.
  def recusar!
    recusada!
  end
end
