require 'rails_helper'

RSpec.describe 'Recargas', type: :request do
  let(:estudante) { User.create!(name: 'Ana Silva', matricula: '231000001', password: 'senha123', saldo: 10) }
  let(:cartao_valido) { { numero: '4111111111111111', nome: 'ANA SILVA', validade: '12/30', cvv: '123' } }

  def entrar
    post login_path, params: { matricula: estudante.matricula, password: 'senha123' }
  end

  it 'manda para o login quem não está logado' do
    get nova_recarga_path
    expect(response).to redirect_to(login_path)
  end

  it 'mostra a página de recarga com o saldo atual' do
    entrar
    get nova_recarga_path
    expect(response.body).to include('Recarga de Saldo', 'R$ 10,00')
  end

  describe 'PIX' do
    before { entrar }

    it 'gera o código PIX e só credita depois da confirmação' do
      post recargas_path, params: { recarga: { metodo: 'pix', valor: '30.00' } }
      recarga = Recarga.last
      expect(response).to redirect_to(recarga_path(recarga))
      expect(recarga.codigo_pix).to start_with('PIX-UNBRU-')
      expect(estudante.reload.saldo).to eq(10)

      patch confirmar_recarga_path(recarga)
      expect(estudante.reload.saldo).to eq(40)
    end

    it 'não deixa confirmar a recarga de outro estudante' do
      outro = User.create!(name: 'Bruno Lima', matricula: '231000002', password: 'senha123')
      recarga = outro.recargas.create!(valor: 30, metodo: 'pix', codigo_pix: 'PIX-X')

      patch confirmar_recarga_path(recarga)
      expect(response).to have_http_status(:not_found)
      expect(outro.reload.saldo).to eq(0)
    end
  end

  describe 'valor inválido' do
    before { entrar }

    it 'recusa valor negativo sem criar recarga' do
      expect do
        post recargas_path, params: { recarga: { metodo: 'pix', valor: '-10.00' } }
      end.not_to change(Recarga, :count)
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Valor de recarga inválido')
    end
  end

  describe 'cartão de crédito' do
    before { entrar }

    it 'aprova e credita o valor' do
      post recargas_path, params: { recarga: { metodo: 'cartao_credito', valor: '80.00' }, cartao: cartao_valido }
      expect(Recarga.last).to be_aprovada
      expect(estudante.reload.saldo).to eq(90)
    end

    it 'recusa cartão sem limite e não credita' do
      sem_limite = cartao_valido.merge(numero: GatewayCartao::CARTOES_SEM_LIMITE.first)
      post recargas_path, params: { recarga: { metodo: 'cartao_credito', valor: '80.00' }, cartao: sem_limite }
      expect(Recarga.last).to be_recusada
      expect(estudante.reload.saldo).to eq(10)
    end

    it 'recusa dados de cartão incompletos' do
      expect do
        post recargas_path, params: { recarga: { metodo: 'cartao_credito', valor: '80.00' }, cartao: { numero: '1' } }
      end.not_to change(Recarga, :count)
      expect(response.body).to include('Dados do cartão inválidos')
    end
  end
end