# language: pt
Funcionalidade: Validação de Entrada
  Como estudante
  Eu quero ter minha matrícula validada ao passar na catraca do RU
  Para que eu possa fazer minha refeição usando o saldo da minha conta

  Contexto:
    Dado que o preço da refeição é R$ 4,50

  Esquema do Cenário: Entrada validada com saldo suficiente (Caminho Feliz)
    Dado que o estudante de matrícula "241012345" está cadastrado no sistema do RU
    E o estudante possui saldo de "<saldo_inicial>"
    Quando o estudante apresenta a matrícula "241012345" na catraca
    Então o sistema deve liberar a catraca
    E o saldo do estudante deve ser "<saldo_final>"

    Exemplos:
      | saldo_inicial | saldo_final |
      | R$ 5,00       | R$ 0,50     |
      | R$ 4,50       | R$ 0,00     |

  Cenário: Tentativa de entrada com matrícula não cadastrada (Caminho Triste)
    Dado que o estudante de matrícula "241099999" não está cadastrado no sistema do RU
    Quando o estudante apresenta a matrícula "241099999" na catraca
    Então o sistema deve exibir a mensagem de erro "Usuário não cadastrado no sistema"
    E a catraca não deve ser liberada

  Esquema do Cenário: Tentativa de entrada com saldo insuficiente (Caminho Triste)
    Dado que o estudante de matrícula "241012345" está cadastrado no sistema do RU
    E o estudante possui saldo de "<saldo>"
    Quando o estudante apresenta a matrícula "241012345" na catraca
    Então o sistema deve exibir a mensagem de erro "Saldo insuficiente para a refeição"
    E a catraca não deve ser liberada
    E o saldo do estudante deve permanecer "<saldo>"

    Exemplos:
      | saldo   |
      | R$ 4,49 |
      | R$ 2,00 |

  Esquema do Cenário: Tentativa de entrada com matrícula de formato inválido (Caminho Triste)
    Quando o estudante apresenta a matrícula "<matricula>" na catraca
    Então o sistema deve exibir a mensagem de erro "Matrícula com formato inválido"
    E a catraca não deve ser liberada

    Exemplos:
      | matricula  |
      | 2410123    |
      | 24101234   |
      | 2410123456 |
      | ABCDEFGHI  |
      | 241#12345  |
      |            |
