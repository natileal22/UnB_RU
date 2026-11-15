# frozen_string_literal: true

def estudante_do_feature(nome)
  User.find_or_create_by!(nome: nome) do |usuario|
    usuario.matricula = proxima_matricula('estudante')
    usuario.password = SENHA_DE_TESTE
    usuario.perfil = 'estudante'
  end
end

def instante_do_feature(data, hora = '12:00')
  Time.zone.strptime("#{data} #{hora}", '%d/%m/%Y %H:%M')
end

def acesso_do_estudante(estudante, data:, hora:, catraca:, restaurante:)
  Access.create!(user: estudante, matricula: estudante.matricula, resultado: 'LIBERADO', catraca: catraca,
                 restaurant: Restaurant.find_or_create_by!(name: restaurante),
                 occurred_at: instante_do_feature(data, hora))
end

Dado('que estou autenticado como o estudante {string}') do |nome|
  @usuario_logado = estudante_do_feature(nome)
  visit login_path
  fill_in 'Matrícula', with: @usuario_logado.matricula
  fill_in 'Senha', with: SENHA_DE_TESTE
  click_button 'Entrar'
end

Dado('existem as recargas do estudante {string}:') do |nome, tabela|
  estudante = estudante_do_feature(nome)
  tabela.hashes.each do |linha|
    Recarga.create!(user: estudante, valor: valor_em_reais(linha['valor']), metodo: 'pix', status: 'aprovada',
                    created_at: instante_do_feature(linha['data']))
  end
end

Dado('existem os acessos do estudante {string}:') do |nome, tabela|
  estudante = estudante_do_feature(nome)
  tabela.hashes.each do |linha|
    acesso_do_estudante(estudante, data: linha['data'], hora: linha['hora'], catraca: linha['catraca'],
                                   restaurante: linha['restaurante'])
  end
end

Dado('só existem registros do estudante {string} na página {string}') do |nome, pagina|
  estudante = estudante_do_feature(nome)
  if pagina == 'Extrato de Recargas'
    Recarga.create!(user: estudante, valor: 10, metodo: 'pix', status: 'aprovada',
                    created_at: instante_do_feature('10/09/2026'))
  else
    acesso_do_estudante(estudante, data: '10/09/2026', hora: '12:00', catraca: 'CAT-01',
                                   restaurante: 'RU Darcy Ribeiro')
  end
end
