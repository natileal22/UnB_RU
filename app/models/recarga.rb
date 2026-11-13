class Recarga < ApplicationRecord
  belongs_to :user

  # A validação do valor vem antes do enum para que a mensagem dela apareça primeiro.
  validates :valor, numericality: { greater_than: 0, message: 'de recarga inválido' }

  enum :metodo, { pix: 'pix', cartao_credito: 'cartao_credito' }, validate: true
  enum :status, { pendente: 'pendente', aprovada: 'aprovada', recusada: 'recusada' }

  # Credita o valor no saldo do estudante. A transação garante que o status
  # e o saldo mudam juntos: ou as duas coisas acontecem, ou nenhuma.
  def aprovar!
    raise 'Recarga já processada' unless pendente?

    transaction do
      aprovada!
      user.increment!(:saldo, valor)
    end
  end

  def recusar!
    recusada!
  end
end