# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength -- um describe com a pagina inicial de cada perfil
require 'rails_helper'

# pagina inicial de reserva: porta de entrada, home do estudante e o sair
RSpec.describe 'Inicio', type: :request do
  def entrar_como_estudante(saldo: 0)
    User.create!(name: 'Ana Beatriz', matricula: '241000099', password: 'SenhaForte123', perfil: 'estudante',
                 saldo: saldo)
    post login_path, params: { matricula: '241000099', password: 'SenhaForte123' }
  end

  def entrar_como_operador(perfil)
    User.create!(name: perfil, matricula: '9000001', password: 'SenhaForte123', perfil: perfil)
    post operador_entrar_path, params: { matricula: '9000001', senha: 'SenhaForte123' }
  end

  it 'mostra a porta de entrada ao visitante com os acessos e o login do estudante' do
    get root_path

    expect(response.body).to include('Aplicação no ar', 'RU UnB Digital', 'UNIVERSIDADE DE BRASÍLIA',
                                     operador_entrar_path, new_user_path, cardapio_hoje_path)
    expect(response.body).to match(/<form[^>]+action="#{login_path}"/)
    expect(response.body).to include('Operador (funcionário ou administrador)')
    expect(response.body).not_to include('portal-topo', '>Administrador<')
  end

  it 'mostra saldo, tarifa, refeições garantidas e o botão de recarga ao estudante' do
    entrar_como_estudante(saldo: 18)
    get root_path

    expect(response.body).to include('Olá, Ana', '241000099', 'R$ 18,00', 'R$ 4,50', '4 refeições garantidas',
                                     nova_recarga_path)
    expect(response.body).not_to include('Autenticação do estudante')
  end

  it 'mostra o turno e o cardápio da refeição atual' do
    entrar_como_estudante
    allow(HorarioRefeicao).to receive(:atual).and_return(HorarioRefeicao::REFEICOES[1])
    Cardapio.create!(data: Time.zone.today, refeicao: 'almoco').itens.create!(tipo: 'padrao', item: 'Frango grelhado')
    get root_path

    expect(response.body).to include('Turno atual: Almoço', 'Frango grelhado', 'ver-cardapio-completo')
  end

  it 'mostra a próxima refeição fora do horário' do
    entrar_como_estudante
    allow(HorarioRefeicao).to receive(:atual).and_return(nil)
    get root_path

    expect(response.body).to include('Nenhuma refeição neste momento', 'Próxima refeição')
  end

  it 'leva o funcionário ao ponto de acesso e o administrador à gestão' do
    entrar_como_operador('funcionario')
    get root_path
    expect(response).to redirect_to(ponto_acesso_path)

    delete operador_sair_path
    User.destroy_all
    entrar_como_operador('administrador')
    get root_path
    expect(response).to redirect_to(admin_restaurantes_path)
  end

  it 'encerra a sessão do estudante e volta para a raiz' do
    entrar_como_estudante
    delete sair_path
    expect(response).to redirect_to(root_path)

    get extrato_path
    expect(response).to redirect_to(login_path)
  end
end
# rubocop:enable Metrics/BlockLength
