# Wiki - Sprint 1

**Grupo:**8

**Sprint Entregue:** Sprint 1

**Integrantes:**

* Adriano Lopes - 170097960
* Isabela de Souza - 190088931
* Kassio Gandara de Souza - 180140540
* Natália Leal - 221021581
* Pedro de Paula - 231036050

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
* **Story Points:** 10
* **Regras de Negócio:**
  * RN01: Apenas o administrador pode cadastrar, editar, remover ou alterar o status de restaurantes e catracas.
  * RN02: Toda catraca deve estar vinculada a um único restaurante cadastrado.
  * RN03: O restaurante deve possuir nome único, localização, horário válido (abertura anterior ao fechamento) e capacidade entre 1 e 5000 lugares.
  * RN04: O código identificador da catraca é obrigatório e único dentro de um mesmo restaurante.
  * RN05: Uma catraca só pode ser ativada se o restaurante vinculado estiver "Ativo"; ao inativar um restaurante, suas catracas ativas passam para "Inativa".
  * RN06: Não é permitido remover um restaurante que possua catracas vinculadas nem remover uma catraca que esteja "Ativa".
* **Histórias de Usuário:**
  * H1 (3 pontos): Como administrador, eu quero cadastrar e listar os restaurantes universitários, para que as unidades do RU fiquem disponíveis no sistema.
  * H2 (2 pontos): Como administrador, eu quero editar os dados e alterar o status de funcionamento de um restaurante (Ativo/Inativo), para que as informações da unidade estejam sempre atualizadas.
  * H3 (3 pontos): Como administrador, eu quero cadastrar e listar catracas vinculadas a um restaurante, para que os pontos de acesso de cada unidade sejam controlados.
  * H4 (2 pontos): Como administrador, eu quero editar e alterar o status de uma catraca (Ativa, Inativa ou Em Manutenção), para que apenas catracas operacionais fiquem liberadas para uso.
* **Declaração de Uso de IA:** Foi utilizada IA generativa, Claude (Sonnet 5.5, da Anthropic), na elaboração de rascunhos das histórias, das regras de negócio, dos cenários BDD e desta seção da Wiki referentes à issue #8. As decisões de domínio foram tomadas pelo aluno, que revisou e aprovou cada etapa, e a sintaxe dos cenários foi verificada com o parser oficial do Gherkin.
---

### Funcionalidade: Cardápio da Refeição Atual
* **Responsável:** Natália Leal
* **Story Points:** 
* **Regras de Negócio:**O sistema deve exibir o cardápio correspondente à refeição que está sendo servida no horário atual do sistema. A visualização deve incluir obrigatoriamente as três opções alimentares: Padrão, Ovolactovegetariano e Vegetariano Estrito. Se o acesso ocorrer num horário em que o RU não está a servir refeições, o sistema deve bloquear a visualização de cardápios antigos e informar o horário da próxima refeição disponível. Caso ocorra uma refeição no horário previsto, mas o cardápio não tenha sido previamente registado na base de dados, o sistema deve exibir uma mensagem indicando que o cardápio ainda não foi disponibilizado.
  

## 3. Padrões Adotados pelo Grupo
* **Padrão de Commits:** Utilização do Conventional Commits, como uso de prefixos  `feat:`, `fix:` para organizar o histórico e depois não se perder.
* **Política de Branching:** A partir da branch `sprint-1`, cada membro cria sua branch isolada de feature ou fix. Ao finalizar, abre-se um Pull Request de volta para a branch da sprint.
* **Política de Revisão:** Todo Pull Request deve ser revisado e aprovado por pelo menos um membro diferente do grupo antes de realizar o merge.
