# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength -- um describe com os casos do cliente da api
require 'rails_helper'
require 'tmpdir'

# cliente da api do cardapio sempre com stub, nunca chama a rede nem le o .env de verdade
RSpec.describe CardapioApi::Cliente do
  let(:http) { instance_double(Net::HTTP) }
  let(:resposta) { resposta_http(Net::HTTPOK, '200', '{"dias":[{"data":"2026-11-16"}]}') }
  let(:sem_arquivo) { File.join(Dir.tmpdir, 'sem_env_do_cliente', '.env') }

  def variaveis(token: 'chave-de-teste', url: nil)
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('RU_API_TOKEN').and_return(token)
    allow(ENV).to receive(:[]).with('RU_API_URL').and_return(url)
  end

  # resposta de verdade do Net::HTTP, so o corpo e trocado, porque o cliente confere a classe dela
  def resposta_http(classe, codigo, corpo)
    classe.new('1.1', codigo, 'texto').tap { |resposta| allow(resposta).to receive(:body).and_return(corpo) }
  end

  def responder_com(resposta_do_servidor)
    allow(Net::HTTP).to receive(:start) { |*_args, **_opcoes, &bloco| bloco.call(http) }
    allow(http).to receive(:get).and_return(resposta_do_servidor)
  end

  before do
    stub_const("#{described_class}::ARQUIVO_ENV", sem_arquivo)
    variaveis
  end

  describe '.semana_vigente' do
    it 'devolve a semana lida da resposta e manda a chave no cabeçalho' do
      responder_com(resposta)

      expect(described_class.semana_vigente).to eq('dias' => [{ 'data' => '2026-11-16' }])
      expect(http).to have_received(:get)
        .with('/cardapio/vigente', 'X-API-Key' => 'chave-de-teste', 'Accept' => 'application/json')
    end

    it 'usa a url padrão com https e os tempos limite de 10 e 20 segundos' do
      responder_com(resposta)
      described_class.semana_vigente

      expect(Net::HTTP).to have_received(:start)
        .with('ru-unb-api.vercel.app', 443, use_ssl: true, open_timeout: 10, read_timeout: 20)
    end

    it 'usa a url do ambiente sem a barra do fim' do
      variaveis(url: 'https://exemplo.test:8443/')
      responder_com(resposta)
      described_class.semana_vigente

      expect(Net::HTTP).to have_received(:start)
        .with('exemplo.test', 8443, use_ssl: true, open_timeout: 10, read_timeout: 20)
      expect(http).to have_received(:get).with('/cardapio/vigente', anything)
    end

    it 'lê a chave do .env local quando o ambiente não tem' do
      arquivo = File.join(Dir.mktmpdir, '.env')
      File.write(arquivo, "RU_API_TOKEN=\"do-arquivo\"\n")
      stub_const("#{described_class}::ARQUIVO_ENV", arquivo)
      variaveis(token: nil)
      responder_com(resposta)
      described_class.semana_vigente

      expect(http).to have_received(:get).with('/cardapio/vigente', hash_including('X-API-Key' => 'do-arquivo'))
    end

    it 'prefere a chave do ambiente à do .env local' do
      arquivo = File.join(Dir.mktmpdir, '.env')
      File.write(arquivo, "RU_API_TOKEN=do-arquivo\n")
      stub_const("#{described_class}::ARQUIVO_ENV", arquivo)
      variaveis(token: 'do-ambiente')
      responder_com(resposta)
      described_class.semana_vigente

      expect(http).to have_received(:get).with('/cardapio/vigente', hash_including('X-API-Key' => 'do-ambiente'))
    end

    [nil, '', '   '].each do |token|
      it "lança ErroApi sem chamar a rede quando a chave é #{token.inspect}" do
        variaveis(token: token)
        allow(Net::HTTP).to receive(:start)

        expect { described_class.semana_vigente }.to raise_error(CardapioApi::ErroApi, 'Defina RU_API_TOKEN')
        expect(Net::HTTP).not_to have_received(:start)
      end
    end

    it 'lança ErroApi com o código quando a resposta não é de sucesso' do
      responder_com(resposta_http(Net::HTTPInternalServerError, '500', 'erro'))

      expect { described_class.semana_vigente }.to raise_error(CardapioApi::ErroApi, /500/)
    end

    it 'lança ErroApi também para o 404 e para o 401' do
      [[Net::HTTPNotFound, '404'], [Net::HTTPUnauthorized, '401']].each do |classe, codigo|
        responder_com(resposta_http(classe, codigo, 'erro'))

        expect { described_class.semana_vigente }.to raise_error(CardapioApi::ErroApi, /#{codigo}/)
      end
    end

    it 'lança ErroApi quando a resposta não é um json' do
      responder_com(resposta_http(Net::HTTPOK, '200', 'isto não é json'))

      expect { described_class.semana_vigente }.to raise_error(CardapioApi::ErroApi)
    end

    [SocketError, Timeout::Error, Errno::ECONNREFUSED, OpenSSL::SSL::SSLError].each do |falha|
      it "transforma #{falha} em ErroApi" do
        allow(Net::HTTP).to receive(:start).and_raise(falha)

        expect { described_class.semana_vigente }.to raise_error(CardapioApi::ErroApi)
      end
    end
  end

  describe 'constantes do cardápio' do
    it 'traz os campos de complemento do café, diferentes dos pratos do almoço e do jantar' do
      expect(described_class::REFEICOES['cafe'][:campos]).to eq(
        padrao: 'complemento_padrao', ovolactovegetariano: 'complemento_ovolactovegetariano',
        vegetariano_estrito: 'complemento_vegetariano_estrito'
      )
    end
  end
end
# rubocop:enable Metrics/BlockLength
