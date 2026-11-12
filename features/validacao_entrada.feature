# language: pt
Funcionalidade: Validação de Entrada
  Como estudante
  Eu quero ter minha matrícula validada ao passar na catraca do RU
  Para que eu possa fazer minha refeição usando o saldo da minha conta

  Contexto:
    Dado que o preço da refeição é "R$ 4,50"
    E existe o restaurante "RU Central" com status "Ativo"
    E existe a catraca "CAT-01" com status "Ativa" no restaurante "RU Central"

  Esquema do Cenário: Entrada validada com saldo suficiente (Caminho Feliz)
    Dado que o estudante de matrícula "241012345" está cadastrado no sistema do RU
    E o estudante possui saldo de "<saldo_inicial>"
    Quando o estudante apresenta a matrícula "241012345" na catraca "CAT-01"
    Então o sistema deve liberar a catraca
    E o saldo do estudante deve ser "<saldo_final>"
    E deve ser registrado um acesso "LIBERADO"

    Exemplos:
      | saldo_inicial | saldo_final |
      | R$ 5,00       | R$ 0,50     |
      | R$ 4,50       | R$ 0,00     |

  Cenário: Tentativa de entrada com matrícula não cadastrada (Caminho Triste)
    Dado que o estudante de matrícula "241099999" não está cadastrado no sistema do RU
    Quando o estudante apresenta a matrícula "241099999" na catraca "CAT-01"
    Então o sistema deve exibir a mensagem de erro "Usuário não cadastrado no sistema"
    E a catraca não deve ser liberada
    E deve ser registrado um acesso "NEGADO" com motivo "NAO_CADASTRADO"

  Esquema do Cenário: Tentativa de entrada com saldo insuficiente (Caminho Triste)
    Dado que o estudante de matrícula "241012345" está cadastrado no sistema do RU
    E o estudante possui saldo de "<saldo>"
    Quando o estudante apresenta a matrícula "241012345" na catraca "CAT-01"
    Então o sistema deve exibir a mensagem de erro "Saldo insuficiente para a refeição"
    E a catraca não deve ser liberada
    E o saldo do estudante deve permanecer "<saldo>"
    E deve ser registrado um acesso "NEGADO" com motivo "SALDO_INSUFICIENTE"

    Exemplos:
      | saldo   |
      | R$ 4,49 |
      | R$ 2,00 |

  Esquema do Cenário: Tentativa de entrada com matrícula de formato inválido (Caminho Triste)
    Quando o estudante apresenta a matrícula "<matricula>" na catraca "CAT-01"
    Então o sistema deve exibir a mensagem de erro "Matrícula com formato inválido"
    E a catraca não deve ser liberada
    E deve ser registrado um acesso "NEGADO" com motivo "FORMATO_INVALIDO"

    Exemplos:
      | matricula  |
      | 2410123    |
      | 24101234   |
      | 2410123456 |
      | ABCDEFGHI  |
      | 241#12345  |
      |            |

  Esquema do Cenário: Tentativa de entrada com catraca indisponível (Caminho Triste)
    Dado que existe a catraca "<codigo_catraca>" com status "<status_catraca>" no restaurante "RU Central"
    E o estudante de matrícula "241012345" está cadastrado no sistema do RU
    E o estudante possui saldo de "R$ 5,00"
    Quando o estudante apresenta a matrícula "241012345" na catraca "<codigo_catraca>"
    Então o sistema deve exibir a mensagem de erro "Catraca indisponível"
    E a catraca não deve ser liberada
    E o saldo do estudante deve permanecer "R$ 5,00"
    E deve ser registrado um acesso "NEGADO" com motivo "CATRACA_INDISPONIVEL"

    Exemplos:
      | codigo_catraca | status_catraca |
      | CAT-02         | Inativa        |
      | CAT-03         | Em Manutenção  |
