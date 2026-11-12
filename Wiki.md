# Wiki - Sprint 1

**Grupo:**

**Sprint Entregue:** Sprint 1

**Integrantes:**

* Natália Leal - 221021581
* Pedro de Paula - 231036050
* Kassio Gandara de Souza - 180140540
* Isabela de Souza - 190088931
* Adriano Lopes - 170097960

---

## 1. Papéis da Equipe
* **Scrum Master: Isabela de Souza** 
* **Product Owner (PO): Adriano Lopes** 

## 2. Funcionalidades e Regras de Negócio

### Funcionalidade: Cadastro de Usuário
* **Responsável:** Adriano Lopes
* **Story Points:** 
* **Regras de Negócio:** O cadastro é exclusivo para estudantes com matrícula ativa na UnB. A matrícula deve ser informada em formato válido, possuir exatamente 9 dígitos numéricos e ainda não estar associada a outra conta. O estudante deve informar nome, matrícula, senha. O sistema deve impedir o cadastro quando a matrícula for inválida ou já estiver cadastrada, ou quando houver dados obrigatórios ausentes. Com todos os dados válidos, a conta deve ser criada e o estudante deve ser encaminhado para a página de autenticação.

### Funcionalidade: Recarga de Saldo
* **Responsável:** Natália Leal
* **Story Points:** 
* **Regras de Negócio:** O estudante deve poder recarregar via PIX ou Cartão de Crédito. Valores negativos ou nulos são inválidos. Cartões sem limite devem ter a transação recusada.

### Funcionalidade: Autenticação do Funcionário
* **Responsável:** Pedro de Paula
* **Story Points:**
* **Regras de Negócio:** O funcionário que estiver cadastrado no sistema deve poder se autenticar com usuário (matrícula de 7 dígitos) e senha, sendo redirecionado para a página de Gestão de Restaurantes e Catracas. Tentativas de autenticação com credenciais inválidas (incorretas ou não cadastradas) devem falhar, exibindo mensagem de erro e se mantendo na página de autenticação.
* 
### Funcionalidade: Validação de entrada
* **Responsável:** Isabela de Souza Clímaco (190088931)
* **Story Points:** 3
* **User Story:** Como estudante, eu quero ter minha matrícula validada ao passar na catraca do RU, para que eu possa fazer minha refeição usando o saldo da minha conta.
* **Regras de Negócio:**
  * RN01: A matrícula do estudante deve ter exatamente 9 dígitos numéricos; caso contrário, a entrada é negada com a mensagem "Matrícula com formato inválido".
  * RN02: A catraca aceita apenas estudantes. Matrículas de funcionários (SIAPE, 7 dígitos) são recusadas por formato inválido.
  * RN03: Não há senha na catraca: ela lê apenas a matrícula.
  * RN04: A catraca precisa estar ativa e pertencer a um restaurante ativo; catraca inativa ou em manutenção nega a entrada com "Catraca indisponível".
  * RN05: Se um funcionário configurou o ponto de acesso, a catraca precisa pertencer ao restaurante selecionado; senão, a entrada é negada com "Catraca não pertence ao restaurante selecionado".
  * RN06: Matrícula não cadastrada é negada com "Usuário não cadastrado no sistema".
  * RN07: O preço da refeição é R$ 4,50. A entrada só é liberada com saldo maior ou igual a R$ 4,50; senão, é negada com "Saldo insuficiente para a refeição" e o saldo não muda.
  * RN08: Com tudo válido, a catraca é liberada e R$ 4,50 são debitados do saldo. O débito e o registro do acesso acontecem na mesma transação.
  * RN09: Toda tentativa, liberada ou negada, é registrada em `accesses` com o resultado (LIBERADO/NEGADO), o motivo da negação e o valor cobrado. Esses registros alimentam o Relatório Global de Acessos.
  * Ordem das verificações: formato → catraca → restaurante selecionado → cadastro → saldo.
* **Hipóteses:** preço fixo de R$ 4,50 até existir uma tabela de preços; a validação de horário de refeição está fora do escopo desta história.
* **Como testar:** `bundle exec cucumber features/validacao_entrada.feature` e `bundle exec rspec spec/services/validacao_entrada_spec.rb spec/requests/catracas_spec.rb`

Foi utilizada IA generativa, Claude (Opus 5.5 no chat do claude.ai e [confirmar] no Claude Code, da Anthropic), no planejamento e no plano de ação da sprint, nos rascunhos da história, das regras de negócio e dos cenários BDD, na modelagem da tabela `accesses` e nesta seção da Wiki referentes à issue #6. No chat, a IA ajudou a interpretar o roteiro da disciplina, a montar o passo a passo da implementação com a explicação de cada arquivo e a revisar os cenários e o código. Ao detectar que a branch de autenticação do funcionário (issue do Pedro) colidia com esta implementação (coluna `perfil` duplicada, senha com `has_secure_password` e step de mensagem de erro repetido), a IA simulou o merge e propôs a integração. Os testes foram executados e conferidos localmente (49 exemplos RSpec e 29 cenários Cucumber passando, RuboCop sem erros), e o CI os executa a cada push.  O texto ainda será revisado pela aluna antes da entrega.

### Funcionalidade: Configuração do Ponto de Acesso
* **Responsável:** Isabela de Souza Clímaco (190088931)
* **Story Points:** 5
* **User Story:** Como funcionário do restaurante, eu quero selecionar, logo após o login, em qual restaurante vou operar, para que o sistema direcione as regras corretamente e grave os logs com o restaurante correto.
* **Regras de Negócio:**
  * RN01: Somente funcionários e administradores podem configurar o ponto de acesso. Um estudante vê a mensagem "Acesso negado: apenas Funcionários e Administradores podem acessar esta página".
  * RN02: É preciso estar autenticado; sem login, o usuário é redirecionado para a autenticação do operador.
  * RN03: A lista de seleção exibe apenas restaurantes ativos. Se não houver nenhum, o sistema exibe "Nenhum restaurante disponível".
  * RN04: Confirmar sem escolher um restaurante exibe "Selecione um restaurante para continuar".
  * RN05: Um restaurante inativo enviado diretamente é recusado com "Restaurante indisponível para operação".
  * RN06: Após a seleção, o restaurante fica guardado na sessão do funcionário e ele é direcionado para a tela de operação, que mostra o nome do restaurante e suas catracas.
  * RN07: Com o ponto de acesso configurado, a Validação de Entrada só aceita catracas do restaurante selecionado.
* **Hipóteses:** a seleção fica na sessão (sem tabela nova); trocar de restaurante sem sair do sistema está fora do escopo.
* **Como testar:** `bundle exec cucumber features/configuracao_ponto_acesso.feature` e `bundle exec rspec spec/requests/pontos_acesso_spec.rb`

Foi utilizada IA generativa, Claude (Opus 5.5 no chat do claude.ai e [confirmar] no Claude Code, da Anthropic), no plano de ação, nos rascunhos da história, das regras de negócio e dos cenários BDD e nesta seção da Wiki referentes à issue #5. A comparação com a issue de gestão de restaurantes e catracas, para separar o que já estava coberto pelo colega do que era exclusivo desta issue, também foi feita com apoio da IA. A implementação (controllers, telas, steps do Cucumber e specs do RSpec) foi gerada pelo Claude Code em etapas com aprovação da aluna, adaptada à autenticação do funcionário (perfis `estudante`, `funcionario` e `administrador` e login do operador). Para evitar conflito entre steps, os passos compartilhados foram reunidos em `features/step_definitions/comum_steps.rb`, e o step de mensagem de erro da feature de autenticação foi reaproveitado. Os cenários foram verificados com o Cucumber (todos passando) antes da entrega. O texto ainda será revisado pela aluna antes da entrega.

### Funcionalidade: Gestão de restaurantes e catracas
* **Responsável:** Kassio Gandara de Souza
* **Story Points:** 6 (H8a: 3 + H8b: 3)
* **Regras de Negócio:**
  * Restaurantes (H8a):
    * O nome é obrigatório, não pode ter só espaços e deve ser único. A comparação ignora maiúsculas, minúsculas e espaços nas pontas.
    * A localização é obrigatória e não pode ter só espaços.
    * A capacidade é um número inteiro de 1 a 5000, em refeições por hora (ref/hora), como mostra o protótipo do Figma. Valores como 0, 5001, negativos, decimais ou texto são rejeitados.
    * O horário de abertura deve ser anterior ao de fechamento. Horários iguais também são rejeitados. Como o horário pode acabar sendo definido por turno, esse ponto ainda será confirmado com o grupo.
    * Inativar um restaurante inativa as catracas ativas dele e mantém as que estão em manutenção, tudo na mesma operação. Se a gravação das catracas falhar, o restaurante continua ativo. Reativar o restaurante não reativa as catracas.
    * Só é possível remover um restaurante que não tenha catracas vinculadas, e a remoção pede confirmação.
    * Só o administrador cadastra, edita, inativa ou remove restaurantes. O funcionário vê a página apenas para leitura, e qualquer ação administrativa dele é negada com mensagem de erro. Se a sessão expirar, o usuário volta para a página de autenticação.
  * Catracas (H8b):
    * O código da catraca é obrigatório, tem até 20 caracteres e aceita só letras, dígitos e hífen. Espaço, `#` e `/` são rejeitados. A tela mostra "Catraca NN" quando o código segue o formato `CAT-NN`; nos outros casos, mostra o próprio código.
    * O código é único dentro do restaurante, sem diferenciar maiúsculas, minúsculas e espaços nas pontas. O mesmo código pode existir em outro restaurante.
    * Toda catraca pertence a um único restaurante, escolhido pelo administrador no cadastro. Não existe catraca sem restaurante.
    * O administrador também escolhe o funcionário responsável pela catraca, que precisa ter o perfil de funcionário. A escolha do responsável é opcional no cadastro (a confirmar com o grupo). Cada catraca tem no máximo um responsável, e um funcionário pode responder por mais de uma catraca. O funcionário não escolhe a catraca.
    * Os status possíveis são ativa, inativa e em manutenção. Não se cadastra nem se ativa catraca em restaurante inativo.
    * A catraca recusa a entrada fora do horário cadastrado do restaurante e quando está indisponível, isto é, inativa, em manutenção ou em restaurante inativo (essa regra depende da feature de Validação de Entrada, da Isabela, e ainda não tem cenário aqui).
    * Catraca ativa não pode ser removida. Catraca inativa ou em manutenção pode ser removida, depois de confirmar a ação, desde que não tenha registros de acesso nem responsável. Se tiver, ela não é apagada e só pode ser inativada (a confirmar com o grupo).
    * Só o administrador gerencia catracas e define os responsáveis. O funcionário vê a lista apenas para leitura, e na Aplicação de Controle aparecem só as catracas vinculadas a ele que estejam ativas em restaurantes ativos. Qualquer ação administrativa do funcionário é negada com mensagem de erro.
* **Histórias de Usuário:**
  * H8a (3 pontos): Como administrador, eu quero cadastrar, editar e remover restaurantes, para que as catracas e os funcionários da Aplicação de Controle saibam quais unidades existem e em que estado estão.
  * H8b (3 pontos): Como administrador, eu quero cadastrar, editar e remover as catracas físicas de cada restaurante, para que os funcionários possam selecioná-las na Aplicação de Controle.
* **Declaração de Uso de IA:** Foi utilizada IA generativa, Claude (Sonnet 5.5 e Haiku 5.5, da Anthropic), na elaboração de rascunhos das histórias, das regras de negócio, dos cenários BDD e desta seção da Wiki referentes à issue #8, com agentes especializados coordenados pelo Maestri e a skill humanizer-pt-br na redação. Os agentes trabalham em fila, as entregas passam por pareceres de outros agentes de IA e são conferidas no disco, e os prompts constam no histórico das sessões; a estratégia completa está no relatório da Etapa 2. As decisões de domínio são do aluno. Algumas propostas da IA, como a catraca com registros de acesso ou responsável só poder ser inativada, o funcionário poder responder por mais de uma catraca, reativar um restaurante não reativar as catracas e a unidade da capacidade, ainda dependem de confirmação do grupo. A IA também escreveu o código de infraestrutura do projeto (configuração do Rails, banco PostgreSQL, tarefas rake e README), revisado por agentes de IA. A sintaxe dos cenários foi verificada com o parser oficial do Gherkin. O texto ainda será revisado pelo aluno antes da entrega.

### Funcionalidade: Extrato e Histórico
* **Responsável:** Kassio Gandara de Souza
* **Story Points:** 4 (H3a: 2 + H3b: 2)
* **Regras de Negócio:**
  * Extrato de recargas (H3a):
    * O estudante vê apenas as próprias recargas, nunca as de outro usuário.
    * As recargas aparecem da mais recente para a mais antiga.
    * O filtro tem data inicial e data final. A data inicial não pode ser posterior à final, e nesse caso o filtro é rejeitado com mensagem.
    * As datas seguem o formato dd/mm/aaaa. Datas inexistentes (como 30/02/2026) ou texto são rejeitados.
    * Sem recargas, a tela mostra uma mensagem de lista vazia, e não uma tabela em branco nem um erro.
    * Sem login, a página não abre e o usuário é levado para a autenticação. Quem está logado com outro perfil recebe acesso negado com mensagem.
  * Histórico de refeições (H3b):
    * O estudante vê apenas os próprios registros de acesso, com data e hora, catraca e restaurante.
    * Os acessos recusados também aparecem, com o motivo, mas só existem se a Validação de Entrada passar a gravá-los (a combinar com a Isabela).
    * Os registros aparecem do mais recente para o mais antigo.
    * O filtro tem data inicial e data final, e a inicial deve ser menor ou igual à final. Intervalo invertido é rejeitado.
    * As datas seguem o formato dd/mm/aaaa. Datas inexistentes e texto são rejeitados.
    * Sem refeições, a tela mostra uma mensagem de lista vazia.
    * Sem login, a página não abre e o usuário é levado para a autenticação. Funcionário e administrador recebem acesso negado com mensagem.
* **Histórias de Usuário:**
  * H3a (2 pontos): Como estudante, eu quero visualizar meu extrato de recargas, para que eu tenha controle sobre meus gastos.
  * H3b (2 pontos): Como estudante, eu quero visualizar meu histórico de refeições, para que eu tenha controle sobre minhas utilizações.
* **Declaração de Uso de IA:** Foi utilizada IA generativa, Claude (Sonnet 5.5 e Haiku 5.5, da Anthropic), na elaboração de rascunhos das histórias, das regras de negócio, dos cenários BDD e desta seção da Wiki referentes à issue #3, com agentes especializados coordenados pelo Maestri e a skill humanizer-pt-br na redação. Os agentes trabalham em fila, as entregas passam por pareceres de outros agentes de IA e são conferidas no disco, e os prompts constam no histórico das sessões; a estratégia completa está no relatório da Etapa 2. As decisões de domínio são do aluno. Algumas propostas da IA, como a ordem do mais recente para o mais antigo, a mensagem de lista vazia e o acesso negado a outros perfis, ainda dependem de confirmação do grupo. A sintaxe dos cenários também foi verificada com o parser oficial do Gherkin. O texto ainda será revisado pelo aluno antes da entrega.

### Funcionalidade: Histórico Local da Catraca
* **Responsável:** Kassio Gandara de Souza
* **Story Points:** 2 (H7: 2)
* **Regras de Negócio:**
  * A lista traz apenas os acessos das catracas sob responsabilidade do funcionário logado. Acessos de catraca de outro responsável, mesmo do mesmo restaurante, não aparecem. Quem vincula cada catraca ao funcionário é o administrador, e o funcionário não escolhe a catraca.
  * Os acessos recusados entram na lista, com o motivo, desde que a Validação de Entrada passe a gravá-los (a combinar com a Isabela).
  * O funcionário sem nenhuma catraca vinculada vê a tela sem registros e uma mensagem para procurar o administrador.
  * O filtro tem data inicial e data final, e a inicial deve ser menor ou igual à final. Intervalo invertido é rejeitado.
  * As datas seguem o formato dd/mm/aaaa e as horas o formato HH:MM. Valores inválidos são rejeitados.
  * Catraca sem acessos no período mostra uma mensagem de lista vazia.
  * Só o funcionário acessa. Sem login, a página não abre e o usuário é levado para a autenticação. Os outros perfis recebem acesso negado com mensagem. O histórico completo do campus é da funcionalidade de Relatório Global de Acessos, que é de outro integrante.
* **Histórias de Usuário:**
  * H7 (2 pontos): Como funcionário, eu quero visualizar na aplicação de controle o histórico de todos os acessos registrados apenas na catraca que estou gerenciando no momento, para realizar auditorias ou conferências locais de fluxo.
* **Declaração de Uso de IA:** Foi utilizada IA generativa, Claude (Sonnet 5.5 e Haiku 5.5, da Anthropic), na elaboração de rascunhos da história, das regras de negócio, dos cenários BDD e desta seção da Wiki referentes à issue #7, com agentes especializados coordenados pelo Maestri e a skill humanizer-pt-br na redação. Os agentes trabalham em fila, as entregas passam por pareceres de outros agentes de IA e são conferidas no disco, e os prompts constam no histórico das sessões; a estratégia completa está no relatório da Etapa 2. As decisões de domínio são do aluno. Algumas propostas da IA, como o formato HH:MM para horas, a mensagem de lista vazia e a mensagem para funcionário sem catraca vinculada, ainda dependem de confirmação do grupo. A sintaxe dos cenários também foi verificada com o parser oficial do Gherkin. O texto ainda será revisado pelo aluno antes da entrega.

### Funcionalidade: Exportação em PDF do Relatório de Operação
* **Responsável:** Kassio Gandara de Souza
* **Story Points:** 3 (H12: 3)
* **Regras de Negócio:**
  * Os dados vêm do relatório entregue pelo outro integrante na funcionalidade de Relatório Global de Acessos. A exportação não duplica filtros nem agrupamento, e ainda é preciso confirmar com o grupo se os dois são o mesmo relatório.
  * O PDF só é gerado quando o relatório tem pelo menos um registro. Sem dados, o sistema avisa e não entrega arquivo vazio.
  * O PDF reflete o relatório exibido na tela. As colunas que entram serão definidas junto com o grupo.
  * A data inicial deve ser menor ou igual à final, e o período é informado em dd/mm/aaaa. Intervalo inválido bloqueia a exportação.
  * O PDF traz o período, a data e hora de emissão e o nome do administrador que exportou, para servir à auditoria (formato a confirmar com o grupo).
  * Só o administrador exporta. O "administrador geral do sistema" da issue é tratado como o perfil de administrador. Quem não é administrador recebe acesso negado com mensagem.
  * Se a geração do PDF falhar, o sistema mostra uma mensagem de erro e não baixa arquivo parcial.
* **Histórias de Usuário:**
  * H12 (3 pontos): Como administrador geral do sistema, eu quero exportar em PDF o Relatório Global de Operação, para fazer auditoria interna.
* **Declaração de Uso de IA:** Foi utilizada IA generativa, Claude (Sonnet 5.5 e Haiku 5.5, da Anthropic), na elaboração de rascunhos da história, das regras de negócio, dos cenários BDD e desta seção da Wiki referentes à issue #12, com agentes especializados coordenados pelo Maestri e a skill humanizer-pt-br na redação. Os agentes trabalham em fila, as entregas passam por pareceres de outros agentes de IA e são conferidas no disco, e os prompts constam no histórico das sessões; a estratégia completa está no relatório da Etapa 2. As decisões de domínio são do aluno. Algumas propostas da IA, como exportar só quando há dados no período e a mensagem de falha na geração, ainda dependem de confirmação do grupo. A sintaxe dos cenários também foi verificada com o parser oficial do Gherkin. O texto ainda será revisado pelo aluno antes da entrega.

**Total de Story Points do Kassio na Sprint 1:** 15 (Gestão de restaurantes e catracas: 6; Extrato e Histórico: 4; Histórico Local da Catraca: 2; Exportação em PDF do Relatório de Operação: 3)

### Funcionalidade: Relatório global de acessos
* **Responsável:** Adriano
* **Story Points:** 
* **User Story:** Como administrador, eu quero visualizar o histórico completo de todos os acessos do campus, podendo filtrar e agrupar os dados por restaurante e por catraca específica, para ter uma visão gerencial de toda a operação.
* **Regras de Negócio:**
  * RN01: Apenas o administrador pode visualizar o relatório global de acessos.
  * RN02: O relatório deve registrar e exibir todas as tentativas de entrada, tanto as liberadas quanto as negadas.
  * RN03: Cada registro deve apresentar, quando disponível, a matrícula e o nome do estudante, o restaurante, a catraca, o resultado, o valor cobrado e a data e hora do acesso.
  * RN04: O administrador deve poder filtrar os registros por restaurante, catraca específica, período e resultado.
  * RN05: O administrador deve poder agrupar os registros por restaurante e, dentro de cada restaurante, por catraca.
  * RN06: O relatório deve exibir uma mensagem informativa quando não houver registros para os filtros selecionados.
  * RN07: Os registros devem ser preservados para consulta histórica e auditoria, sem alteração ou exclusão pelo relatório.
---

## 3. Padrões Adotados pelo Grupo
* **Padrão de Commits:** Utilização do Conventional Commits, como uso de prefixos  `feat:`, `fix:` para organizar o histórico e depois não se perder.
* **Política de Branching:** A partir da branch `sprint-1`, cada membro cria sua branch isolada de feature ou fix. Ao finalizar, abre-se um Pull Request de volta para a branch da sprint.
* **Política de Revisão:** Todo Pull Request deve ser revisado e aprovado por pelo menos um membro diferente do grupo antes de realizar o merge.
