# language: pt
Funcionalidade: Configuração do Ponto de Acesso
  Como funcionário do restaurante
  Eu quero selecionar, logo após o login, em qual restaurante vou operar
  Para que o sistema direcione as regras corretamente e grave os logs com o restaurante correto

  Cenário: Lista de seleção exibe apenas restaurantes ativos (Caminho Feliz)
    Dado que estou logado como "FUNCIONARIO"
    E existe o restaurante "RU Central" com status "Ativo"
    E existe o restaurante "RU FGA" com status "Inativo"
    Quando acesso a tela de seleção de ponto de acesso
    Então o restaurante "RU Central" deve aparecer na lista de seleção
    E o restaurante "RU FGA" não deve aparecer na lista de seleção

  Esquema do Cenário: Seleção de restaurante ativo com sucesso (Caminho Feliz)
    Dado que estou logado como "<perfil>"
    E estou na página de seleção de ponto de acesso
    E existe o restaurante "RU Central" com status "Ativo"
    Quando seleciono o restaurante "RU Central" na lista
    E clico no botão "Confirmar"
    Então devo ser direcionado para a operação do restaurante "RU Central"
    E o nome "RU Central" deve aparecer na tela de operação

    Exemplos:
      | perfil      |
      | FUNCIONARIO |
      | ADMIN       |

  Cenário: Tentativa de confirmar ponto de acesso sem selecionar restaurante (Caminho Triste)
    Dado que estou logado como "FUNCIONARIO"
    E estou na página de seleção de ponto de acesso
    E existe o restaurante "RU Central" com status "Ativo"
    Quando clico no botão "Confirmar" sem selecionar nenhum restaurante
    Então o sistema deve exibir a mensagem de erro "Selecione um restaurante para continuar"
    E o ponto de acesso não deve ser configurado

  Cenário: Tentativa de selecionar restaurante inativo diretamente (Caminho Triste)
    Dado que estou logado como "FUNCIONARIO"
    E estou na página de seleção de ponto de acesso
    E existe o restaurante "RU FGA" com status "Inativo"
    Quando tento selecionar diretamente o restaurante "RU FGA" como ponto de acesso
    Então o sistema deve exibir a mensagem de erro "Restaurante indisponível para operação"
    E o ponto de acesso não deve ser configurado

  Cenário: Configuração indisponível quando não há restaurantes ativos (Caminho Triste)
    Dado que estou logado como "FUNCIONARIO"
    E não existe nenhum restaurante com status "Ativo"
    Quando acesso a tela de seleção de ponto de acesso
    Então o sistema deve exibir a mensagem "Nenhum restaurante disponível"
    E o ponto de acesso não deve ser configurado

  Cenário: Usuário com perfil ALUNO tenta acessar a configuração (Caminho Triste)
    Dado que estou logado como "ALUNO"
    Quando tento acessar a tela de seleção de ponto de acesso
    Então o sistema deve exibir a mensagem de erro "Acesso negado: apenas Funcionários e Administradores podem acessar esta página"
    E o ponto de acesso não deve ser configurado

  Cenário: Tentativa de acesso à configuração sem autenticação (Caminho Triste)
    Dado que não estou autenticado no sistema
    Quando tento acessar a tela de seleção de ponto de acesso
    Então o sistema deve redirecionar para a página de autenticação
    E o ponto de acesso não deve ser configurado

  Cenário: Validação de entrada com catraca de restaurante diferente do selecionado (Caminho Triste)
    Dado que estou logado como "FUNCIONARIO"
    E existe o restaurante "RU Central" com status "Ativo"
    E existe o restaurante "RU FGA" com status "Ativo"
    E existe a catraca "CAT-10" com status "Ativa" no restaurante "RU FGA"
    E o ponto de acesso está configurado para o restaurante "RU Central"
    E o estudante de matrícula "241012345" está cadastrado no sistema do RU
    E o estudante possui saldo de "R$ 5,00"
    Quando o estudante apresenta a matrícula "241012345" na catraca "CAT-10"
    Então o sistema deve exibir a mensagem de erro "Catraca não pertence ao restaurante selecionado"
    E a catraca não deve ser liberada
    E o saldo do estudante deve permanecer "R$ 5,00"
    E deve ser registrado um acesso "NEGADO" com motivo "CATRACA_FORA_DO_RESTAURANTE"
