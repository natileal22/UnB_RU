# frozen_string_literal: true

require 'yaml'

# dados de demonstracao para os testadores, as tabelas ficam em demo.yml
# pode rodar a cada deploy sem duplicar nem trocar a senha de conta que ja existe
# uso: bin/rails demo:popular
module DadosDemo
  module_function

  ARQUIVO = File.expand_path('demo.yml', __dir__)

  # le uma tabela de demonstracao do arquivo, que so e lido uma vez
  # args: nome (Symbol) da tabela: usuarios, restaurantes, catracas, acessos ou recargas
  # retorna: lista de hashes com as colunas de cada linha
  # efeito: le o arquivo demo.yml na primeira chamada
  def tabela(nome)
    @tabelas ||= YAML.safe_load_file(ARQUIVO, aliases: true, symbolize_names: true)
    @tabelas.fetch(nome)
  end

  # cria as tabelas na ordem certa, catraca precisa de restaurante e responsavel, acesso e recarga de estudante
  # args: nenhum
  # retorna: nada de util
  # efeito: grava no banco so o que ainda nao existe
  def popular_tudo
    popular(User, tabela(:usuarios), %i[matricula])
    popular(Restaurant, tabela(:restaurantes), %i[name])
    popular(Catraca, tabela(:catracas), %i[restaurant codigo])
    popular(Access, tabela(:acessos), %i[matricula catraca resultado motivo_negacao restaurant])
    popular(Recarga, tabela(:recargas), %i[user valor metodo status])
  end

  # cria cada linha da tabela que ainda nao existe, o que ja existe fica como esta
  # args: modelo (classe do ActiveRecord), linhas (lista de hashes) e chaves (colunas que identificam a linha)
  # retorna: a lista de linhas
  # efeito: grava no banco so as linhas novas, sem tocar nas que ja existem e sem usar a data, que e relativa
  def popular(modelo, linhas, chaves)
    linhas.each do |dados|
      ligado = ligar(dados)
      modelo.find_or_create_by!(ligado.slice(*chaves)) { |registro| registro.assign_attributes(ligado.except(*chaves)) }
    end
  end

  # troca o nome, a matricula e o par de dias e hora pelo registro ou pela data que a coluna espera
  # args: dados (Hash) de uma linha da tabela
  # retorna: o mesmo hash com restaurante, usuario e momento ja resolvidos
  # efeito: so le o banco
  def ligar(dados)
    dados.to_h do |coluna, valor|
      case coluna
      when :restaurant then [coluna, Restaurant.find_by!(name: valor)]
      when :user, :responsavel then [coluna, User.find_by(matricula: valor)]
      when :occurred_at, :created_at then [coluna, momento(*valor)]
      else [coluna, valor]
      end
    end
  end

  # data e hora de alguns dias atras
  # args: dias_atras (Integer) e hora (String hh:mm), meio-dia por padrao
  # retorna: Time no fuso da aplicacao
  # efeito: nenhum
  def momento(dias_atras, hora = '12:00')
    horas, minutos = hora.split(':').map(&:to_i)
    (Time.zone.today - dias_atras).in_time_zone.change(hour: horas, min: minutos)
  end
end

namespace :demo do
  desc 'Cria contas, restaurantes, catracas, acessos e recargas de demonstracao sem duplicar'
  task popular: :environment do
    DadosDemo.popular_tudo

    puts "Demonstracao pronta: #{User.count} usuarios, #{Restaurant.count} restaurantes, #{Catraca.count} catracas, " \
         "#{Access.count} acessos e #{Recarga.count} recargas."
  end
end
