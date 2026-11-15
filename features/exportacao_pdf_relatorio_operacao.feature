# language: pt

@issue-12
Funcionalidade: Exportação em PDF do relatório de operação
  Como administrador geral do sistema
  Eu quero exportar em PDF o Relatório Global de Operação
  Para fazer auditoria interna
  O PDF cobre o período informado e aceita filtro opcional de restaurante e de catraca
  O nome do arquivo inclui a catraca quando ela está filtrada
  Os filtros de resultado e de agrupamento do relatório não entram no PDF

  @feliz @pdf @rack_test @hipotese
  Cenário: Exportar o período aplicado no relatório (Caminho Feliz)
    Dado que estou autenticado como "Administrador"
    E existem registros de acesso no período de "01/09/2026" a "30/09/2026"
    E estou na página "Relatório Global de Operação"
    E o período de "01/09/2026" a "30/09/2026" está aplicado no relatório
    Quando clico em "#exportar-pdf"
    Então a resposta deve ter status 200
    E o cabeçalho "Content-Type" da resposta deve conter "application/pdf"
    E o cabeçalho "Content-Disposition" da resposta deve conter "relatorio_operacao_2026-09-01_a_2026-09-30.pdf"
    E o PDF deve conter "Total de acessos: 2"
    E o PDF deve conter "NEGADO"

  @feliz @pdf @rack_test @filtro
  Cenário: Exportar apenas os acessos de uma catraca (Caminho Feliz)
    Dado que estou autenticado como "Administrador"
    E existem registros de acesso no período de "01/09/2026" a "30/09/2026"
    E estou na página "Relatório Global de Operação"
    E o período de "01/09/2026" a "30/09/2026" está aplicado no relatório
    E a catraca "CAT-01" está filtrada no relatório
    Quando clico em "#exportar-pdf"
    Então a resposta deve ter status 200
    E o cabeçalho "Content-Disposition" da resposta deve conter "relatorio_operacao_CAT-01_2026-09-01"
    E o PDF deve conter "Catraca: CAT-01"
    E o PDF deve conter "Total de acessos: 1"
    E o PDF deve conter "241012345"
    E o PDF não deve conter "241012346"

  @feliz @pdf @rack_test @filtro
  Cenário: Exportar apenas os acessos de um restaurante (Caminho Feliz)
    Dado que estou autenticado como "Administrador"
    E existem registros de acesso no período de "01/09/2026" a "30/09/2026"
    E existe um acesso da matrícula "241099999" no restaurante "RU Gama" em "10/09/2026"
    E estou na página "Relatório Global de Operação"
    E o período de "01/09/2026" a "30/09/2026" está aplicado no relatório
    E o restaurante "RU Gama" está filtrado no relatório
    Quando clico em "#exportar-pdf"
    Então a resposta deve ter status 200
    E o PDF deve conter "Restaurante: RU Gama"
    E o PDF deve conter "241099999"
    E o PDF não deve conter "241012345"

  @feliz @pdf @rack_test @filtro
  Cenário: Exportar sem aplicar o filtro de resultado do relatório (Caminho Feliz)
    Dado que estou autenticado como "Administrador"
    E existem registros de acesso no período de "01/09/2026" a "30/09/2026"
    E estou na página "Relatório Global de Operação"
    E o período de "01/09/2026" a "30/09/2026" está aplicado no relatório
    E o resultado "Liberado" está filtrado no relatório
    Quando clico em "#exportar-pdf"
    Então a resposta deve ter status 200
    E o PDF deve conter "NEGADO"
    E o PDF deve conter "241012346"
    E o PDF deve conter "Total de acessos: 2"

  @triste @pdf @rack_test @hipotese
  Cenário: Redirecionar para a autenticação quando não há login (Caminho Triste)
    Dado que minha sessão expirou
    Quando envio uma requisição GET para a rota de exportação com data inicial "01/09/2026" e final "30/09/2026"
    Então devo ser redirecionado para a página "Autenticação"
    E o cabeçalho "Content-Type" da resposta não deve conter "application/pdf"

  @triste @pdf @rack_test @hipotese
  Cenário: Avisar quando não há registros no período (Caminho Triste)
    Dado que estou autenticado como "Administrador"
    E não existem registros de acesso no período de "01/09/2026" a "30/09/2026"
    E estou na página "Relatório Global de Operação"
    E o período de "01/09/2026" a "30/09/2026" está aplicado no relatório
    Quando clico em "#exportar-pdf"
    Então a resposta deve ter status 422
    E o elemento "#flash-alert" deve ter o texto "Não há registros no período para exportar"
    E o cabeçalho "Content-Type" da resposta não deve conter "application/pdf"

  @triste @pdf @rack_test @hipotese
  Esquema do Cenário: Bloquear a exportação com período inválido (Caminho Triste)
    Dado que estou autenticado como "Administrador"
    Quando envio uma requisição GET para a rota de exportação com data inicial "<inicial>" e final "<final>"
    Então a resposta deve ter status 422
    E o elemento "#flash-alert" deve ter o texto "<mensagem>"
    E o cabeçalho "Content-Type" da resposta não deve conter "application/pdf"

    Exemplos:
      | inicial    | final      | mensagem                                          |
      | 30/09/2026 | 01/09/2026 | A data inicial não pode ser posterior à data final |
      | 31/02/2026 | 28/02/2026 | Data inválida: use o formato dd/mm/aaaa           |
      | 01/09/2026 | abc        | Data inválida: use o formato dd/mm/aaaa           |
      |            |            | Data inválida: use o formato dd/mm/aaaa           |

  @triste @pdf @rack_test @hipotese
  Cenário: Mostrar erro quando a geração do PDF falha (Caminho Triste)
    Dado que estou autenticado como "Administrador"
    E existem registros de acesso no período de "01/09/2026" a "30/09/2026"
    E a geração do PDF falha com erro
    E estou na página "Relatório Global de Operação"
    E o período de "01/09/2026" a "30/09/2026" está aplicado no relatório
    Quando clico em "#exportar-pdf"
    Então a resposta deve ter status 500
    E o elemento "#flash-alert" deve ter o texto "Não foi possível gerar o PDF. Tente novamente"
    E o cabeçalho "Content-Type" da resposta não deve conter "application/pdf"

  @triste @pdf @rack_test @hipotese
  Esquema do Cenário: Negar a exportação a quem não é administrador (Caminho Triste)
    Dado que estou autenticado como "<perfil>"
    Quando envio uma requisição GET para a rota de exportação com data inicial "01/09/2026" e final "30/09/2026"
    Então a resposta deve ter status 403
    E o elemento "#flash-alert" deve ter o texto "Acesso negado: apenas o Administrador pode exportar o relatório"
    E o cabeçalho "Content-Type" da resposta não deve conter "application/pdf"

    Exemplos:
      | perfil      |
      | Funcionário |
      | Estudante   |
