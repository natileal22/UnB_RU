Quando('eu abro a página inicial da aplicação') do
  visit root_path
end

Então('devo ver a mensagem de saúde {string}') do |texto|
  expect(page).to have_content(texto)
end
