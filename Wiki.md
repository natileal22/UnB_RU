# Wiki - Sprint 1

**Grupo:**

**Sprint Entregue:** Sprint 1

**Integrantes:**

* Natália Leal - 221021581
* Pedro de Paula - 231036050
* Nome do Colega 1 - Matrícula 1
* Nome do Colega 2 - Matrícula 2

---

## 1. Papéis da Equipe
* **Scrum Master:** 
* **Product Owner (PO):** 

## 2. Funcionalidades e Regras de Negócio

### Funcionalidade: Cadastro de Usuário
* **Responsável:** [Nome do Colega]
* **Story Points:** 
* **Regras de Negócio:** [Colega preenche]

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
* **Responsável:** [Nome do Colega]
* **Story Points:**
* **Regras de Negócio:** [Colega preenche]
---

## 3. Padrões Adotados pelo Grupo
* **Padrão de Commits:** Utilização do Conventional Commits, como uso de prefixos  `feat:`, `fix:` para organizar o histórico e depois não se perder.
* **Política de Branching:** A partir da branch `sprint-1`, cada membro cria sua branch isolada de feature ou fix. Ao finalizar, abre-se um Pull Request de volta para a branch da sprint.
* **Política de Revisão:** Todo Pull Request deve ser revisado e aprovado por pelo menos um membro diferente do grupo antes de realizar o merge.
