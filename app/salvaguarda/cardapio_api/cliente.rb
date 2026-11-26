# frozen_string_literal: true

require 'json'
require 'net/http'

module CardapioApi
  # Cliente HTTP isolado da API do cardapio do RU na Vercel, so le a semana vigente
  class Cliente
    URL_PADRAO = 'https://ru-unb-api.vercel.app'
    ARQUIVO_ENV = File.expand_path('.env', __dir__)
    # a chave viaja no cabecalho entao a conexao e sempre https, com tempo limite para conectar e para ler
    OPCOES_HTTP = { use_ssl: true, open_timeout: 10, read_timeout: 20 }.freeze
    # falhas de rede, de status e de leitura que viram ErroApi, assim quem chama trata um erro so
    FALHAS = [SocketError, SystemCallError, Timeout::Error, OpenSSL::SSL::SSLError, Net::HTTPExceptions,
              JSON::ParserError].freeze
    # refeicao do sistema para a chave que a api usa
    MAPA_REFEICOES = { 'cafe' => 'cafe_da_manha', 'almoco' => 'almoco', 'jantar' => 'jantar' }.freeze
    # em cada refeicao, o tipo de opcao do sistema e o campo da api com o prato dela
    CAMPOS_PRINCIPAIS = {
      padrao: 'prato_principal_padrao',
      ovolactovegetariano: 'prato_principal_ovolactovegetariano',
      vegetariano_estrito: 'prato_principal_vegetariano_estrito'
    }.freeze
    CAMPOS_CAFE = CAMPOS_PRINCIPAIS.transform_values { |campo| campo.sub('prato_principal', 'complemento') }.freeze
    CAMPOS = { 'cafe' => CAMPOS_CAFE, 'almoco' => CAMPOS_PRINCIPAIS, 'jantar' => CAMPOS_PRINCIPAIS }.freeze

    class << self
      # busca a semana vigente do cardapio na api
      # args: nenhum, a url e a chave vem do ambiente ou do .env local
      # retorna: hash com a lista dias da semana, ou lanca ErroApi se faltar a chave, a rede cair ou a resposta for ruim
      # efeito: faz uma requisicao HTTPS GET e nao grava nada
      def semana_vigente
        buscar('/cardapio/vigente')
      end

      private

      # faz o GET autenticado e devolve o JSON da resposta
      # args: caminho (String) do endpoint, por exemplo /cardapio/vigente
      # retorna: o hash lido da resposta, ou lanca ErroApi quando o status nao e de sucesso ou a falha e de rede
      # efeito: abre uma conexao https com tempo limite de 10 s para conectar e 20 s para ler
      def buscar(caminho)
        JSON.parse(ler(uri_de(caminho), chave_de_acesso))
      rescue *FALHAS => e
        raise ErroApi, e.message
      end

      # a conversa com o servidor, que so devolve o corpo quando o status e de sucesso
      # args: uri (URI) do endpoint e chave (String) da api
      # retorna: o corpo (String) da resposta, ou lanca Net::HTTPExceptions para status 3xx, 4xx e 5xx
      # efeito: abre e fecha uma conexao https e envia a chave no cabecalho X-API-Key
      def ler(uri, chave)
        resposta = Net::HTTP.start(uri.host, uri.port, **OPCOES_HTTP) do |http|
          http.get(uri.request_uri, 'X-API-Key' => chave, 'Accept' => 'application/json')
        end
        resposta.value
        resposta.body
      end

      # endereco do endpoint a partir da url do ambiente ou da padrao
      # args: caminho (String) do endpoint
      # retorna: URI completa, sem barra duplicada entre a url e o caminho
      # efeito: nenhum
      def uri_de(caminho)
        URI("#{(variavel('RU_API_URL').presence || URL_PADRAO).chomp('/')}#{caminho}")
      end

      # chave da api sem espacos nas pontas
      # args: nenhum
      # retorna: a chave (String) ou lanca ErroApi quando ela nao foi definida
      # efeito: nenhum, so le o ambiente
      def chave_de_acesso
        variavel('RU_API_TOKEN').to_s.strip.presence || raise(ErroApi, 'Defina RU_API_TOKEN')
      end

      # le a variavel do ambiente e, se faltar, do .env local, que so existe em desenvolvimento e teste
      # args: nome (String) da variavel
      # retorna: o valor (String) ou nil quando nao existe em lugar nenhum
      # efeito: le o arquivo .env quando a gem dotenv esta carregada, nao altera o ambiente
      def variavel(nome)
        ENV[nome].presence || (Dotenv.parse(ARQUIVO_ENV)[nome] if defined?(Dotenv))
      end
    end
  end
end
