# O Rails só protege o ambiente production contra tarefas que apagam o banco. Como o desenvolvimento pode apontar para o
# Supabase (DATABASE_URL remota), estas tarefas recusam rodar em qualquer ambiente cujo banco não seja local.
# Para rodar de propósito contra um servidor remoto: PERMITIR_BANCO_REMOTO=sim bin/rails db:setup
desc "Recusa tarefas destrutivas quando o banco do ambiente atual não é local"
task protecao_remota: :environment do
  config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).first
  host = config&.configuration_hash&.dig(:host).to_s
  local = host.empty? || %w[localhost 127.0.0.1 ::1].include?(host)

  next if local || ENV["PERMITIR_BANCO_REMOTO"] == "sim"

  abort <<~MSG
    Tarefa recusada: o banco de #{Rails.env} fica em #{host}, que não é local.
    Essa tarefa apaga ou recria o banco. Se for isso mesmo que você quer, rode de novo com PERMITIR_BANCO_REMOTO=sim.
  MSG
end

# A trava entra na FRENTE dos pré-requisitos: o Rails confere o ambiente protegido (e abre conexão) antes das ações da tarefa.
%w[db:drop db:reset db:setup db:schema:load db:purge db:migrate:reset].each do |nome|
  next unless Rake::Task.task_defined?(nome)

  Rake::Task[nome].prerequisites.unshift("protecao_remota")
end
