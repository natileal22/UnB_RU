# frozen_string_literal: true

require 'date'
require 'json'
require 'net/http'
require 'uri'

module CardapioApi
  # Cliente HTTP isolado para consumir a API do cardapio do RU na Vercel
  class Cliente # rubocop:disable Metrics/ClassLength -- cliente da api e importacao ficam no mesmo arquivo
    ENV_PATH = File.expand_path('.env', __dir__)
    URL_PADRAO = 'https://ru-unb-api.vercel.app'
    DIAS_SEMANA = %w[
      domingo segunda-feira terca-feira quarta-feira quinta-feira sexta-feira sabado
    ].freeze
    CAMPOS_LISTA = %w[bebidas panificacao molho_para_salada acompanhamentos].freeze
    MAPA_REFEICOES = {
      'cafe' => 'cafe_da_manha',
      'almoco' => 'almoco',
      'jantar' => 'jantar'
    }.freeze
    CAMPOS_CAFE = {
      padrao: 'complemento_padrao',
      ovolactovegetariano: 'complemento_ovolactovegetariano',
      vegetariano_estrito: 'complemento_vegetariano_estrito'
    }.freeze
    CAMPOS_PRINCIPAIS = {
      padrao: 'prato_principal_padrao',
      ovolactovegetariano: 'prato_principal_ovolactovegetariano',
      vegetariano_estrito: 'prato_principal_vegetariano_estrito'
    }.freeze

    class << self
      # Retorna o JSON completo da semana vigente da API
      def semana_vigente
        buscar('/cardapio/vigente')
      end

      # Retorna o JSON da proxima semana quando disponivel
      def proxima_semana
        buscar('/cardapio/proxima-semana')
      end

      # Retorna o payload completo com semana vigente e proxima semana
      def completo
        buscar('/cardapio')
      end

      # Converte a lista de dias da API para o formato do cardapio json local
      def para_cardapio_json(semana = nil)
        dados = semana || semana_vigente
        Array(dados['dias']).each_with_object({}) do |dia, saida|
          data = Date.iso8601(dia.fetch('data'))
          chave_dia = DIAS_SEMANA.fetch(data.wday)
          saida[chave_dia] = normalizar_refeicoes(dia['refeicoes'] || {})
        end
      end

      # Salva a semana vigente da API nas tabelas Cardapio e ItemCardapio
      def importar_semana_vigente!
        dados = semana_vigente
        dias = Array(dados['dias'])
        dias.sum { |dia| importar_dia(dia) }
      end

      private

      # Busca um endpoint autenticado da API e devolve o hash JSON
      def buscar(caminho)
        cfg = carregar_env
        token = cfg.fetch(:token)
        raise ErroApi, 'Defina RU_API_TOKEN no arquivo env' if token.empty?

        resposta = executar_get("#{cfg.fetch(:url)}#{caminho}", token)
        JSON.parse(resposta.body)
      rescue JSON::ParserError => e
        raise ErroApi, "JSON invalido da API #{e.message}"
      end

      # Carrega URL e senha primeiro do ambiente e depois do arquivo env local
      def carregar_env
        arquivo = ler_arquivo_env
        url = (ENV['RU_API_URL'] || arquivo['RU_API_URL'] || URL_PADRAO).to_s.strip
        token = (ENV['RU_API_TOKEN'] || arquivo['RU_API_TOKEN'] || '').to_s.strip
        { url: url.chomp('/'), token: token }
      end

      # Le pares chave valor do arquivo env sem alterar o ambiente global
      def ler_arquivo_env
        return {} unless File.file?(ENV_PATH)

        File.readlines(ENV_PATH, chomp: true).each_with_object({}) do |linha, mapa|
          texto = linha.strip
          next if texto.empty? || texto.start_with?('#') || !texto.include?('=')

          chave, valor = texto.split('=', 2)
          mapa[chave.strip] = valor.strip.gsub(/\A['"]|['"]\z/, '')
        end
      end

      # Executa requisicao HTTPS GET enviando a chave no header X-API-Key
      def executar_get(url_completa, token)
        uri = URI.parse(url_completa)
        requisicao = Net::HTTP::Get.new(uri)
        requisicao['X-API-Key'] = token
        requisicao['Accept'] = 'application/json'

        resposta = Net::HTTP.start(uri.host, uri.port, **opcoes_http(uri)) do |http|
          http.request(requisicao)
        end
        return resposta if resposta.is_a?(Net::HTTPSuccess)

        raise ErroApi, "HTTP #{resposta.code} #{resposta.body}"
      end

      # Parametros de conexao HTTP com SSL e timeouts seguros
      def opcoes_http(uri)
        { use_ssl: uri.scheme == 'https', open_timeout: 10, read_timeout: 20 }
      end

      # Ajusta campos da API para ficar igual ao schema esperado pela rake task
      def normalizar_refeicoes(refeicoes)
        refeicoes.transform_values { |bloco| bloco.is_a?(Hash) ? ajustar_bloco(bloco) : nil }
      end

      # Renomeia a bebida e quebra os campos de lista em varios itens
      def ajustar_bloco(bloco)
        ajustado = bloco.transform_keys { |k| k == 'bebida_refresco' ? 'bebida' : k }
        CAMPOS_LISTA.each do |campo|
          valor = ajustado[campo]
          ajustado[campo] = valor.split(' / ').map(&:strip) if valor.is_a?(String)
        end
        ajustado
      end

      # Persiste as tres refeicoes de um dia no banco do Rails
      def importar_dia(dia)
        data = Date.iso8601(dia.fetch('data'))
        refeicoes = dia['refeicoes'] || {}
        MAPA_REFEICOES.count do |refeicao, chave_json|
          bloco = refeicoes[chave_json]
          next false unless bloco.is_a?(Hash)

          salvar_refeicao(data, refeicao, bloco)
          true
        end
      end

      # Cria ou atualiza um Cardapio e seus itens principais
      def salvar_refeicao(data, refeicao, bloco)
        cardapio = Cardapio.find_or_create_by!(data: data, refeicao: refeicao)
        cardapio.itens.destroy_all
        campos = refeicao == 'cafe' ? CAMPOS_CAFE : CAMPOS_PRINCIPAIS
        campos.each do |tipo, campo|
          texto = bloco[campo].to_s.strip
          cardapio.itens.create!(tipo: tipo, item: texto) unless texto.empty?
        end
      end
    end
  end
end
