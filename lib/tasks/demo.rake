# frozen_string_literal: true

# dados de demonstracao para os testadores
# pode rodar a cada deploy sem duplicar nem trocar a senha de conta que ja existe
# uso: bin/rails demo:popular
module DadosDemo # rubocop:disable Metrics/ModuleLength -- tabelas de dados da demonstracao
  module_function

  def usuarios # rubocop:disable Metrics/MethodLength -- tabela de dados
    aluno = { perfil: 'estudante', password: 'Aluno@2026' }
    funcionario = { perfil: 'funcionario', password: 'Funcionario@2026', saldo: 0 }
    [
      aluno.merge(nome: 'Ana Souza', matricula: '241012345', saldo: 18),
      aluno.merge(nome: 'Bruno Lima', matricula: '241012346', saldo: 9),
      aluno.merge(nome: 'Carla Mendes', matricula: '241012347', saldo: 0),
      aluno.merge(nome: 'Diego Alves', matricula: '241012348', saldo: 4.5),
      aluno.merge(nome: 'Elisa Rocha', matricula: '241012349', saldo: 50),
      funcionario.merge(nome: 'Maria Fiscal', matricula: '1234567'),
      funcionario.merge(nome: 'João Operador', matricula: '2345678'),
      { nome: 'Administrador RU', matricula: '7654321', perfil: 'administrador', password: 'Admin@2026', saldo: 0 }
    ]
  end

  def restaurantes
    [
      { name: 'RU Darcy Ribeiro', status: 'ativo', localizacao: 'Campus Darcy Ribeiro', capacidade: 800,
        horario_abertura: '11:00', horario_fechamento: '15:00' },
      { name: 'RU Gama', status: 'ativo', localizacao: 'Campus Gama', capacidade: 300,
        horario_abertura: '11:30', horario_fechamento: '14:30' },
      { name: 'RU Planaltina', status: 'inativo', localizacao: 'Campus Planaltina', capacidade: 200,
        horario_abertura: '11:30', horario_fechamento: '14:00' }
    ]
  end

  # responsavel e a matricula do funcionario e so a CAT-01 do Darcy tem janela propria
  def catracas
    [
      { restaurante: 'RU Darcy Ribeiro', codigo: 'CAT-01', status: 'ativa', responsavel: '1234567',
        horario_abertura: '11:00', horario_fechamento: '15:00' },
      { restaurante: 'RU Darcy Ribeiro', codigo: 'CAT-02', status: 'ativa', responsavel: '1234567' },
      { restaurante: 'RU Darcy Ribeiro', codigo: 'CAT-03', status: 'em_manutencao' },
      { restaurante: 'RU Gama', codigo: 'CAT-01', status: 'ativa', responsavel: '2345678' },
      { restaurante: 'RU Planaltina', codigo: 'CAT-01', status: 'inativa' }
    ]
  end

  # cada combinacao de estudante, lugar, resultado e motivo aparece uma vez, e isso evita duplicar com datas relativas
  def acessos # rubocop:disable Metrics/MethodLength -- tabela de dados
    darcy = { restaurante: 'RU Darcy Ribeiro' }
    saldo = { resultado: 'NEGADO', motivo_negacao: 'SALDO_INSUFICIENTE' }
    liberado = { resultado: 'LIBERADO' }
    [
      darcy.merge(liberado, matricula: '241012345', catraca: 'CAT-01', dias: 0, hora: '11:45'),
      darcy.merge(liberado, matricula: '241012346', catraca: 'CAT-01', dias: 1, hora: '12:10'),
      darcy.merge(liberado, matricula: '241012349', catraca: 'CAT-01', dias: 1, hora: '13:00'),
      darcy.merge(liberado, matricula: '241012348', catraca: 'CAT-01', dias: 3, hora: '11:20'),
      darcy.merge(saldo, matricula: '241012347', catraca: 'CAT-01', dias: 0, hora: '12:05'),
      darcy.merge(liberado, matricula: '241012345', catraca: 'CAT-02', dias: 2, hora: '12:30'),
      darcy.merge(liberado, matricula: '241012346', catraca: 'CAT-02', dias: 4, hora: '11:55'),
      darcy.merge(saldo, matricula: '241012347', catraca: 'CAT-02', dias: 2, hora: '13:15'),
      darcy.merge(resultado: 'NEGADO', motivo_negacao: 'CATRACA_INDISPONIVEL', matricula: '241012348',
                  catraca: 'CAT-03', dias: 1, hora: '12:40'),
      liberado.merge(restaurante: 'RU Gama', matricula: '241012349', catraca: 'CAT-01', dias: 0, hora: '12:20'),
      liberado.merge(restaurante: 'RU Gama', matricula: '241012345', catraca: 'CAT-01', dias: 3, hora: '12:50'),
      { restaurante: 'RU Planaltina', matricula: '241012346', catraca: 'CAT-01', resultado: 'NEGADO',
        motivo_negacao: 'CATRACA_INDISPONIVEL', dias: 5, hora: '11:40' }
    ]
  end

  # cada combinacao de estudante, valor, metodo e status aparece uma vez
  def recargas
    [
      { matricula: '241012345', valor: 30, metodo: 'pix', status: 'aprovada', dias: 6 },
      { matricula: '241012345', valor: 20, metodo: 'cartao_credito', status: 'aprovada', dias: 2 },
      { matricula: '241012346', valor: 10, metodo: 'pix', status: 'pendente', dias: 1 },
      { matricula: '241012347', valor: 15, metodo: 'cartao_credito', status: 'recusada', dias: 3 },
      { matricula: '241012348', valor: 5, metodo: 'pix', status: 'aprovada', dias: 4 },
      { matricula: '241012349', valor: 50, metodo: 'pix', status: 'aprovada', dias: 5 }
    ]
  end

  # so cria quando nao existe, o que ja existe fica como esta
  def criar(modelo, chave)
    registro = modelo.find_or_initialize_by(chave)
    return registro unless registro.new_record?

    yield registro
    registro.save!
    registro
  end

  def momento(dias_atras, hora = '12:00')
    horas, minutos = hora.split(':').map(&:to_i)
    (Time.zone.today - dias_atras).in_time_zone.change(hour: horas, min: minutos)
  end

  def popular_usuarios
    usuarios.each do |dados|
      criar(User, matricula: dados[:matricula]) do |usuario|
        usuario.assign_attributes(dados.merge(email: "#{dados[:nome].parameterize(separator: '.')}@exemplo.unb.br"))
      end
    end
  end

  def popular_restaurantes
    restaurantes.each do |dados|
      criar(Restaurant, name: dados[:name]) { |restaurante| restaurante.assign_attributes(dados) }
    end
  end

  def popular_catracas
    catracas.each do |dados|
      restaurante = Restaurant.find_by!(name: dados[:restaurante])
      criar(Catraca, restaurant: restaurante, codigo: dados[:codigo]) do |catraca|
        responsavel = User.find_by!(matricula: dados[:responsavel]) if dados[:responsavel]
        catraca.assign_attributes(dados.except(:restaurante, :codigo, :responsavel).merge(responsavel: responsavel))
      end
    end
  end

  def popular_acessos
    acessos.each do |dados|
      criar(Access, chave_do_acesso(dados)) do |acesso|
        acesso.user = User.find_by!(matricula: dados[:matricula])
        acesso.occurred_at = momento(dados[:dias], dados[:hora])
        acesso.valor_cobrado = ValidacaoEntrada::PRECO if dados[:resultado] == 'LIBERADO'
      end
    end
  end

  def chave_do_acesso(dados)
    dados.slice(:matricula, :catraca, :resultado, :motivo_negacao)
         .merge(restaurant: Restaurant.find_by!(name: dados[:restaurante]))
  end

  def popular_recargas
    recargas.each_with_index do |dados, indice|
      chave = dados.slice(:valor, :metodo, :status).merge(user: User.find_by!(matricula: dados[:matricula]))
      criar(Recarga, chave) do |recarga|
        recarga.created_at = momento(dados[:dias])
        recarga.codigo_pix = format('PIX-UNBRU-DEMO%04d', indice) if dados[:metodo] == 'pix'
      end
    end
  end
end

namespace :demo do
  desc 'Cria contas, restaurantes, catracas, acessos e recargas de demonstracao sem duplicar'
  task popular: :environment do
    # a ordem importa, catraca precisa de restaurante e responsavel, acesso e recarga de estudante
    %i[popular_usuarios popular_restaurantes popular_catracas popular_acessos popular_recargas].each do |etapa|
      DadosDemo.public_send(etapa)
    end

    puts "Demonstracao pronta: #{User.count} usuarios, #{Restaurant.count} restaurantes, #{Catraca.count} catracas, " \
         "#{Access.count} acessos e #{Recarga.count} recargas."
  end
end
