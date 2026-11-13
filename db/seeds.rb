# Sample data for the Sprint 2 features. This seed is safe to run more than once.

users = [
  { name: "Ana Silva", matricula: "123456789", email: "ana.silva@unb.br", password: "SenhaForte123" },
  { name: "Bruno Oliveira", matricula: "202012345", email: "bruno.oliveira@unb.br", password: "AcessoRU456" }
]

users.each do |attributes|
  user = User.find_or_initialize_by(matricula: attributes[:matricula])
  user.assign_attributes(attributes)
  user.save!
end

restaurants = {
  "RU Darcy Ribeiro" => [
    { catraca: "CAT-01", matricula: "241012345", resultado: "LIBERADO", occurred_at: "2026-10-20 08:15:00" },
    { catraca: "CAT-02", matricula: "241012346", resultado: "NEGADO", occurred_at: "2026-10-20 12:30:00" }
  ],
  "RU Gama" => [
    { catraca: "CAT-01", matricula: "241012347", resultado: "LIBERADO", occurred_at: "2026-10-21 11:45:00" }
  ]
}

restaurants.each do |name, accesses|
  restaurant = Restaurant.find_or_create_by!(name: name)

  accesses.each do |attributes|
    occurred_at = Time.zone.parse(attributes.fetch(:occurred_at))
    access = restaurant.accesses.find_or_initialize_by(
      catraca: attributes[:catraca],
      matricula: attributes[:matricula],
      occurred_at: occurred_at
    )
    access.assign_attributes(resultado: attributes[:resultado])
    access.save!
  end
end

User.find_or_create_by!(matricula: "1234567") do |u|
  u.nome = "Operador RU Darcy"
  u.password = "SenhaCorreta123"
  u.perfil = "funcionario"
end

puts "Seed concluída: #{User.count} usuários, #{Restaurant.count} restaurantes e #{Access.count} acessos."
