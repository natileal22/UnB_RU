# language: pt

@issue-12
Funcionalidade: Exportação em PDF do relatório de operação
  Como administrador geral do sistema
  Eu quero exportar em PDF o Relatório Global de Operação
  Para fazer auditoria interna

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

  @triste @pdf @rack_test @hipotese
  Cenário: Avisar quando não há registros no período (Caminho Triste)
    Dado que estou autenticado como "Administrador"
    E não existem registros de acesso no período de "01/09/2026" a "30/09/2026"
    E estou na página "Relatório Global de Operação"
    E o período de "01/09/2026" a "30/09/2026" está aplicado no relatório
    Quando clico em "#exportar-pdf"
    Então o elemento "#flash-alert" deve ter o texto "Não há registros no período para exportar"
    E o cabeçalho "Content-Type" da resposta não deve conter "application/pdf"

  @triste @pdf @rack_test @hipotese
  Esquema do Cenário: Bloquear a exportação com período inválido (Caminho Triste)
    Dado que estou autenticado como "Administrador"
    Quando envio uma requisição GET para a rota de exportação com data inicial "<inicial>" e data final "<final>"
    Então o elemento "#flash-alert" deve ter o texto "<mensagem>"
    E o cabeçalho "Content-Type" da resposta não deve conter "application/pdf"

    Exemplos:
      | inicial    | final      | mensagem                                          |
      | 30/09/2026 | 01/09/2026 | A data inicial não pode ser posterior à data final |
      | 31/02/2026 | 28/02/2026 | Data inválida: use o formato dd/mm/aaaa           |
      | 01/09/2026 | abc        | Data inválida: use o formato dd/mm/aaaa           |

  @triste @pdf @rack_test @hipotese
  Cenário: Mostrar erro quando a geração do PDF falha (Caminho Triste)
    Dado que estou autenticado como "Administrador"
    E existem registros de acesso no período de "01/09/2026" a "30/09/2026"
    E a geração do PDF falha com erro
    E estou na página "Relatório Global de Operação"
    E o período de "01/09/2026" a "30/09/2026" está aplicado no relatório
    Quando clico em "#exportar-pdf"
    Então o elemento "#flash-alert" deve ter o texto "Não foi possível gerar o PDF. Tente novamente"
    E o cabeçalho "Content-Type" da resposta não deve conter "application/pdf"

  @triste @pdf @rack_test @hipotese
  Esquema do Cenário: Negar a exportação a quem não é administrador (Caminho Triste)
    Dado que estou autenticado como "<perfil>"
    Quando envio uma requisição GET para a rota de exportação com data inicial "01/09/2026" e data final "30/09/2026"
    Então a resposta deve ter status 403
    E o elemento "#flash-alert" deve ter o texto "Acesso negado: apenas o Administrador pode exportar o relatório"
    E o cabeçalho "Content-Type" da resposta não deve conter "application/pdf"

    Exemplos:
      | perfil      |
      | Funcionário |
      | Estudante   |
