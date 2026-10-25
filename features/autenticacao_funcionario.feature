Funcionalidade: Autenticação de Funcionário
  Como funcionário do restaurante
  Eu quero fazer login na aplicação de controle
  Para autenticar minha sessão e operar o sistema de forma segura

  Esquema do Cenário: Login bem-sucedido com credenciais válidas (Caminho Feliz)
    Dado que o funcionário possui uma conta ativa no sistema
    E está na página de autenticação do operador
    Quando ele preenche a credencial "<usuario>" e a senha "<senha>"
    E clica no botão "Entrar no Sistema"
    Então o sistema deve autenticar a sessão com sucesso
    E redirecionar o funcionário para a página de Gestão de Restaurantes e Catracas

    Exemplos:
        | usuario          | senha           |
        | 1234567          | SenhaCorreta123 |
        | 4120918          | JnL8osgaWJNdfd  |

  Esquema do Cenário: Tentativa de login com senha incorreta (Caminho Triste)
    Dado que o funcionário possui uma conta ativa no sistema
    E está na página de autenticação do operador
    Quando ele preenche a credencial "<usuario>"
    Mas insere a senha incorreta "<senha>"
    E clica no botão "Entrar no Sistema"
    Então o sistema deve exibir a mensagem de erro "Credenciais inválidas"
    E a sessão não deve ser iniciada
    E o usuário deve permanecer na página de autenticação do operador

    Exemplos:
        | usuario          | senha            |
        | 1234567          | SenhaInorreta123 |
        | 4120918          | JnL8osgaWJNdfe   |

  Cenário: Tentativa de login sem preencher campos obrigatórios (Caminho Triste)
    Dado que o funcionário está na página de autenticação do operador
    Quando ele tenta clicar no botão "Entrar no Sistema" sem preencher o usuário e a senha
    Então o sistema deve exibir um alerta "Preencha todos os campos obrigatórios"
    E a sessão não deve ser iniciada
    E o usuário deve permanecer na página de autenticação do operador

  Cenário: Tentativa de login de funcionário não cadastrado
    Dado que o usuário não está cadastrado como funcionário
    E está na página de autenticação do operador
    Quando ele preenche a credencial "0101010" e a senha "QualquerSenha123"
    E clica no botão "Entrar no Sistema"
    Então o sistema deve exibir a mensagem de erro "Credenciais inválidas"
    E a sessão não deve ser iniciada
    E o usuário deve permanecer na página de autenticação do operador