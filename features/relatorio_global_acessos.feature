Funcionalidade: Relatório global de acessos
  Como administrador
  Eu quero visualizar o histórico completo de todos os acessos do campus
  Podendo filtrar e agrupar os dados por restaurante e por catraca específica
  Para ter uma visão gerencial de toda a operação

  Contexto:
    Dado que estou logado como "Administrador"
    E estou na página de Relatório Global de Acessos

  Cenário: Visualizar o histórico completo de acessos do campus (Caminho Feliz)
    Dado que existem os seguintes registros de acesso:
      | restaurante       | catraca | matrícula | resultado | data       |
      | RU Darcy Ribeiro  | CAT-01  | 241012345 | LIBERADO  | 2026-10-20 |
      | RU Darcy Ribeiro  | CAT-02  | 241012346 | NEGADO    | 2026-10-20 |
      | RU Gama           | CAT-01  | 241012347 | LIBERADO  | 2026-10-21 |
    Quando consulto o relatório sem aplicar filtros
    Então o sistema deve exibir todos os 3 registros de acesso
    E deve exibir o restaurante, a catraca, a matrícula, o resultado e a data de cada registro

  Esquema do Cenário: Filtrar acessos por restaurante
    Dado que existem registros de acesso nos restaurantes "RU Darcy Ribeiro" e "RU Gama"
    Quando filtro o relatório pelo restaurante "<restaurante>"
    Então o sistema deve exibir apenas os acessos do restaurante "<restaurante>"
    E não deve exibir acessos de outros restaurantes

    Exemplos:
      | restaurante      |
      | RU Darcy Ribeiro |
      | RU Gama          |

  Cenário: Filtrar acessos por catraca específica
    Dado que existem os seguintes registros de acesso:
      | restaurante      | catraca | matrícula | resultado |
      | RU Darcy Ribeiro | CAT-01  | 241012345 | LIBERADO  |
      | RU Darcy Ribeiro | CAT-02  | 241012346 | LIBERADO  |
    Quando filtro o relatório pela catraca "CAT-01" do restaurante "RU Darcy Ribeiro"
    Então o sistema deve exibir apenas os acessos da catraca "CAT-01"
    E não deve exibir acessos da catraca "CAT-02"

  Cenário: Agrupar acessos por restaurante e catraca
    Dado que existem os seguintes registros de acesso:
      | restaurante      | catraca | resultado |
      | RU Darcy Ribeiro | CAT-01  | LIBERADO  |
      | RU Darcy Ribeiro | CAT-01  | NEGADO    |
      | RU Darcy Ribeiro | CAT-02  | LIBERADO  |
      | RU Gama          | CAT-01  | LIBERADO  |
    Quando seleciono o agrupamento por restaurante e catraca
    Então o sistema deve agrupar os registros por restaurante
    E dentro de cada restaurante deve agrupar os registros por catraca
    E deve exibir a quantidade de acessos de cada grupo

  Cenário: Filtrar acessos por período e resultado
    Dado que existem acessos registrados entre "2026-10-01" e "2026-10-31"
    E existem acessos com resultado "LIBERADO" e "NEGADO"
    Quando filtro o período de "2026-10-20" até "2026-10-21"
    E filtro o resultado por "NEGADO"
    Então o sistema deve exibir apenas os acessos negados nesse período
    E não deve exibir acessos fora do período informado
    E não deve exibir acessos LIBERADOs

  Cenário: Relatório sem acessos para os filtros informados
    Dado que não existem acessos para a catraca "CAT-99"
    Quando filtro o relatório pela catraca "CAT-99"
    Então o sistema deve exibir a mensagem "Nenhum acesso encontrado para os filtros informados"
    E não deve exibir registros de outras catracas

  Cenário: Funcionário sem permissão para visualizar o relatório
    Dado que estou logado como "Funcionário"
    Quando tento acessar diretamente a página de Relatório Global de Acessos
    Então o sistema deve exibir a mensagem "Acesso negado: apenas o Administrador pode realizar esta ação"
    E não deve exibir os registros de acesso
