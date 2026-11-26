# frozen_string_literal: true

# Importa o cardapio.json (cardápio semanal do RU) para a semana atual.
# Uso: bin/rails cardapio:importar
namespace :cardapio do
  # Importa o +cardapio.json+ da raiz do projeto para os dias da semana atual.
  #
  # Argumentos:: nenhum. Lê o arquivo +cardapio.json+ e usa a data de hoje para
  #   achar a segunda-feira da semana.
  # Retorno:: nenhum; imprime no terminal quantas refeições existem no banco.
  # Efeitos colaterais::
  #   Altera o banco: cria o Cardapio de cada refeição da semana (se ainda não
  #   existir) e troca os itens dele pelos do arquivo. Pode rodar de novo sem
  #   duplicar cardápios. Lança erro se o arquivo não existir ou não for JSON válido.
  desc 'Importa o cardapio.json para os dias da semana atual'
  task importar: :environment do
    dias = %w[segunda-feira terca-feira quarta-feira quinta-feira sexta-feira sabado domingo]
    refeicoes = { 'cafe' => 'cafe_da_manha', 'almoco' => 'almoco', 'jantar' => 'jantar' }
    campos = {
      'cafe' => { padrao: 'complemento_padrao', ovolactovegetariano: 'complemento_ovolactovegetariano',
                  vegetariano_estrito: 'complemento_vegetariano_estrito' },
      'almoco' => { padrao: 'prato_principal_padrao', ovolactovegetariano: 'prato_principal_ovolactovegetariano',
                    vegetariano_estrito: 'prato_principal_vegetariano_estrito' }
    }
    campos['jantar'] = campos['almoco']

    semana = JSON.parse(Rails.root.join('cardapio.json').read)
    segunda = Time.zone.today.beginning_of_week

    dias.each_with_index do |dia, indice|
      refeicoes.each do |refeicao, chave_json|
        dados = semana.dig(dia, chave_json) or next
        cardapio = Cardapio.find_or_create_by!(data: segunda + indice, refeicao: refeicao)
        cardapio.itens.destroy_all
        campos[refeicao].each do |tipo, campo|
          cardapio.itens.create!(tipo: tipo, item: dados[campo]) if dados[campo].present?
        end
      end
    end

    puts "Cardápio importado para a semana de #{segunda.strftime('%d/%m/%Y')}: #{Cardapio.count} refeições."
  end
end
