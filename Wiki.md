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

**Responsável:** Isabela de Souza Clímaco 

**Story Points:** 

**Regras de Negócio:** A matrícula do estudante deve ter exatamente 9 dígitos numéricos, a catraca aceita apenas estudantes (servidores estão fora do escopo desta história), não há senha: a catraca lê apenas a matrícula, o preço da refeição é R$ 4,50; a entrada só é liberada se o saldo for maior ou igual a R$ 4,50, com matrícula válida, cadastrada e saldo suficiente, a catraca é liberada e R$ 4,50 são debitados do saldo, matrícula com formato inválido, não cadastrada ou com

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
    * O administrador também escolhe o funcionário responsável pela catraca, que precisa ter o perfil de funcionário. Cada catraca tem no máximo um responsável, e um funcionário pode responder por mais de uma catraca. O funcionário não escolhe a catraca.
    * Os status possíveis são ativa, inativa e em manutenção. Não se cadastra nem se ativa catraca em restaurante inativo.
    * A catraca recusa a entrada fora do horário cadastrado do restaurante e quando está indisponível, isto é, inativa, em manutenção ou em restaurante inativo (essa regra depende da feature de Validação de Entrada, da Isabela, e ainda não tem cenário aqui).
    * Catraca ativa não pode ser removida. Catraca inativa ou em manutenção pode ser removida, depois de confirmar a ação, desde que não tenha registros de acesso nem responsável. Se tiver, ela não é apagada e só pode ser inativada (a confirmar com o grupo).
    * Só o administrador gerencia catracas e define os responsáveis. O funcionário vê a lista apenas para leitura, e na Aplicação de Controle aparecem só as catracas vinculadas a ele que estejam ativas em restaurantes ativos. Qualquer ação administrativa do funcionário é negada com mensagem de erro.
* **Histórias de Usuário:**
  * H8a (3 pontos): Como administrador, eu quero cadastrar, editar e remover restaurantes, para que as catracas e os funcionários da Aplicação de Controle saibam quais unidades existem e em que estado estão.
  * H8b (3 pontos): Como administrador, eu quero cadastrar, editar e remover as catracas físicas de cada restaurante, para que os funcionários possam selecioná-las na Aplicação de Controle.
* **Declaração de Uso de IA:** Foi utilizada IA generativa, Claude (Sonnet 5.5 e Haiku 5.5, da Anthropic), na elaboração de rascunhos das histórias, das regras de negócio, dos cenários BDD e desta seção da Wiki referentes à issue #8, com agentes especializados coordenados pelo Maestri e a skill humanizer-pt-br na redação. Os agentes trabalham em fila, as entregas passam por pareceres de outros agentes de IA e são conferidas no disco, e os prompts ficam guardados; a estratégia completa está no relatório da Etapa 2. As decisões de domínio são do aluno. Algumas propostas da IA, como a catraca com registros de acesso ou responsável só poder ser inativada, o funcionário poder responder por mais de uma catraca, reativar um restaurante não reativar as catracas e a unidade da capacidade, ainda dependem de confirmação do grupo. A IA também escreveu o código de infraestrutura do projeto (configuração do Rails, banco PostgreSQL, tarefas rake e README), revisado por agentes de IA. A sintaxe dos cenários foi verificada com o parser oficial do Gherkin. O texto ainda será revisado pelo aluno antes da entrega.

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
* **Declaração de Uso de IA:** Foi utilizada IA generativa, Claude (Sonnet 5.5 e Haiku 5.5, da Anthropic), na elaboração de rascunhos das histórias, das regras de negócio, dos cenários BDD e desta seção da Wiki referentes à issue #3, com agentes especializados coordenados pelo Maestri e a skill humanizer-pt-br na redação. Os agentes trabalham em fila, as entregas passam por pareceres de outros agentes de IA e são conferidas no disco, e os prompts ficam guardados; a estratégia completa está no relatório da Etapa 2. As decisões de domínio são do aluno. Algumas propostas da IA, como a ordem do mais recente para o mais antigo, a mensagem de lista vazia e o acesso negado a outros perfis, ainda dependem de confirmação do grupo. A sintaxe dos cenários também foi verificada com o parser oficial do Gherkin. O texto ainda será revisado pelo aluno antes da entrega.

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
* **Declaração de Uso de IA:** Foi utilizada IA generativa, Claude (Sonnet 5.5 e Haiku 5.5, da Anthropic), na elaboração de rascunhos da história, das regras de negócio, dos cenários BDD e desta seção da Wiki referentes à issue #7, com agentes especializados coordenados pelo Maestri e a skill humanizer-pt-br na redação. Os agentes trabalham em fila, as entregas passam por pareceres de outros agentes de IA e são conferidas no disco, e os prompts ficam guardados; a estratégia completa está no relatório da Etapa 2. As decisões de domínio são do aluno. Algumas propostas da IA, como o formato HH:MM para horas, a mensagem de lista vazia e a mensagem para funcionário sem catraca vinculada, ainda dependem de confirmação do grupo. A sintaxe dos cenários também foi verificada com o parser oficial do Gherkin. O texto ainda será revisado pelo aluno antes da entrega.

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
* **Declaração de Uso de IA:** Foi utilizada IA generativa, Claude (Sonnet 5.5 e Haiku 5.5, da Anthropic), na elaboração de rascunhos da história, das regras de negócio, dos cenários BDD e desta seção da Wiki referentes à issue #12, com agentes especializados coordenados pelo Maestri e a skill humanizer-pt-br na redação. Os agentes trabalham em fila, as entregas passam por pareceres de outros agentes de IA e são conferidas no disco, e os prompts ficam guardados; a estratégia completa está no relatório da Etapa 2. As decisões de domínio são do aluno. Algumas propostas da IA, como exportar só quando há dados no período e a mensagem de falha na geração, ainda dependem de confirmação do grupo. A sintaxe dos cenários também foi verificada com o parser oficial do Gherkin. O texto ainda será revisado pelo aluno antes da entrega.

**Total de Story Points do Kassio na Sprint 1:** 15 (Gestão de restaurantes e catracas: 6; Extrato e Histórico: 4; Histórico Local da Catraca: 2; Exportação em PDF do Relatório de Operação: 3)

---

## 3. Padrões Adotados pelo Grupo
* **Padrão de Commits:** Utilização do Conventional Commits, como uso de prefixos  `feat:`, `fix:` para organizar o histórico e depois não se perder.
* **Política de Branching:** A partir da branch `sprint-1`, cada membro cria sua branch isolada de feature ou fix. Ao finalizar, abre-se um Pull Request de volta para a branch da sprint.
* **Política de Revisão:** Todo Pull Request deve ser revisado e aprovado por pelo menos um membro diferente do grupo antes de realizar o merge.
