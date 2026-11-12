# language: pt
Funcionalidade: Exportação de Extrato e Histórico de Refeições em PDF
  Como estudante
  Eu quero poder exportar meu Extrato e Histórico de Refeições como PDF
  Para poder controlar melhor as minhas finanças

  Contexto:
    Dado que o estudante está autenticado no sistema
    E acessa a página de "Extrato e Histórico de Refeições"

  Cenário: Exportação bem-sucedida do extrato completo (Caminho Feliz)
    Dado que o estudante possui registros no período
    Quando ele clica no botão "Exportar PDF"
    Então o sistema deve enviar um arquivo PDF para o estudante
    E o arquivo baixado deve conter o resumo com "Total Gasto no Mês", "Refeições Realizadas" e "Total Recarregado"
    E deve listar as recargas e acessos correspondentes

  Cenário: Exportação de extrato com filtros aplicados (Caminho Alternativo)
    Dado que o estudante seleciona o período de referência "Últimos 30 dias (Maio/2026)"
    E filtra pelo tipo de refeição "Almoço"
    E filtra pelo restaurante "RU Darcy Ribeiro (Todas as 6 Catracas)"
    Quando ele clica no botão "Exportar PDF"
    Então o sistema deve gerar um arquivo PDF contendo apenas os registros filtrados
    E o cabeçalho do documento PDF deve indicar os filtros aplicados

  Cenário: Falha de conexão ou erro interno na geração do documento (Caminho Triste)
    Dado que o serviço de geração e assinatura digital de relatórios está temporariamente indisponível
    Quando o estudante clica no botão "Exportar PDF"
    Então o sistema deve exibir uma mensagem de erro "Não foi possível gerar o extrato em PDF. Tente novamente mais tarde."
    E o estudante deve permanecer na página de "Extrato e Histórico de Refeições"