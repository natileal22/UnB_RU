# frozen_string_literal: true

# guarda de administrador, carga da tela e fluxo comum de gravar e remover da gestao de restaurantes e catracas
module GestaoAdministrativa
  extend ActiveSupport::Concern

  included do
    layout 'administracao'

    before_action :exigir_login
    # a listagem tambem abre para funcionario e o resto so para administrador
    before_action :exigir_operador!, if: :listagem?
    before_action :exigir_administrador, unless: :listagem?
  end

  # abre a tela unica de gestao, new mostra a mesma tela com o formulario novo aberto
  # args: nenhum
  # retorna: renderiza a listagem com status 200
  # efeito: so le o banco
  def index
    renderizar_gestao
  end
  alias new index

  private

  # a listagem e a unica acao aberta ao funcionario
  # args: nenhum
  # retorna: true quando a acao pedida e index
  # efeito: nenhum
  def listagem?
    action_name == 'index'
  end

  # barra quem nao e administrador nas acoes que alteram dados
  # args: nenhum
  # retorna: nada quando o usuario e administrador, senao renderiza acesso negado com status 403
  # efeito: renderiza e interrompe a acao
  def exigir_administrador
    return if current_user.perfil == 'administrador'

    render 'admin/acesso_negado', status: :forbidden
  end

  # carrega os dados da tela unica e a renderiza
  # args: status (Symbol) da resposta, ok por padrao
  # retorna: renderiza admin/restaurantes/index com restaurantes, responsaveis e os formularios novos
  # efeito: so le o banco
  def renderizar_gestao(status: :ok)
    @restaurantes = Restaurant.includes(catracas: :responsavel).order(Arel.sql('LOWER(restaurants.name)'))
    @responsaveis = User.where(perfil: %w[funcionario administrador]).order(:nome)
    @novo_restaurante ||= Restaurant.new
    @nova_catraca ||= Catraca.new
    render 'admin/restaurantes/index', status: status
  end

  # mostra o primeiro erro de validacao na tela de gestao
  # args: registro (Restaurant ou Catraca) invalido
  # retorna: renderiza a listagem com o erro em flash.now e status 422
  # efeito: nenhum no banco
  def falha_de_validacao(registro)
    flash.now[:alert] = registro.errors.first.message
    renderizar_gestao(status: :unprocessable_content)
  end

  # grava o registro no contexto gestao e volta para a listagem
  # args: registro (Restaurant ou Catraca) com os dados novos e mensagem (String) de sucesso
  # retorna: redireciona para a listagem com a mensagem ou, se for invalido, mostra o erro com status 422
  # efeito: grava no banco quando valido
  def salvar(registro, mensagem)
    return falha_de_validacao(registro) unless registro.save(context: :gestao)

    redirect_to admin_restaurantes_path, notice: mensagem
  end

  # remove o registro quando nada o impede
  # args: registro (Restaurant ou Catraca) e mensagem (String) de sucesso
  # retorna: redireciona para a listagem com a mensagem ou, se nao puder sair, com o motivo no alerta
  # efeito: apaga o registro do banco quando permitido
  def remover(registro, mensagem)
    motivo = registro.motivo_bloqueio_remocao
    return redirect_to admin_restaurantes_path, alert: motivo if motivo

    registro.destroy!
    redirect_to admin_restaurantes_path, notice: mensagem
  end
end
