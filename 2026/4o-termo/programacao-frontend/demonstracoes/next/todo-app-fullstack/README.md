# Todo App Fullstack

Aplicação web para gestão de tarefas, desenvolvida com Next.js. Este documento organiza a descrição e os requisitos do produto segundo as boas práticas de engenharia de requisitos da ISO/IEC/IEEE 29148. Os requisitos abaixo definem o comportamento esperado; detalhes dependentes da implementação devem ser confirmados no projeto.

## 1. Objetivo e visão geral

O sistema deve permitir que uma pessoa organize tarefas num único lugar, acompanhe o seu estado e atualize ou remova tarefas quando necessário.

## 2. Escopo

### Incluído

- Apresentação e gestão de tarefas.
- Criação, consulta, edição e remoção de tarefas.
- Alteração do estado de conclusão de uma tarefa.
- Interface web acessível por navegador.

### Fora do escopo

- Colaboração entre utilizadores, partilha de listas e notificações.
- Sincronização com calendários ou serviços externos.
- Autenticação e autorização, salvo se forem implementadas e especificadas posteriormente.

## 3. Utilizadores e partes interessadas

- **Utilizador final:** organiza e acompanha as suas tarefas.
- **Equipa de desenvolvimento:** implementa, testa e mantém a aplicação.
- **Responsável pelo produto:** valida prioridades e critérios de aceitação.

## 4. Ambiente e contexto

- Aplicação web baseada em Next.js.
- Utilização através de um navegador moderno com JavaScript e ligação à aplicação.
- A interface deve apresentar mensagens claras quando uma operação falhar.
- A tecnologia de persistência e o ambiente de produção dependem da configuração do projeto.

## 5. Requisitos funcionais

Os identificadores são estáveis para facilitar rastreabilidade e testes.

| ID | Requisito | Critério de aceitação |
| --- | --- | --- |
| RF-01 | O sistema deve apresentar as tarefas existentes ao utilizador. | Ao abrir a área de tarefas, são mostradas as tarefas disponíveis ou um estado vazio informativo. |
| RF-02 | O sistema deve permitir criar uma tarefa com uma descrição não vazia. | Após guardar uma descrição válida, a tarefa aparece na lista. Uma descrição vazia é rejeitada com indicação do problema. |
| RF-03 | O sistema deve permitir consultar os dados e o estado de cada tarefa. | A tarefa apresentada contém, no mínimo, a sua descrição e o estado de conclusão. |
| RF-04 | O sistema deve permitir alterar a descrição de uma tarefa existente. | Depois de guardar uma alteração válida, a descrição atualizada é apresentada. |
| RF-05 | O sistema deve permitir marcar uma tarefa como concluída e voltar a marcá-la como pendente. | A ação altera o estado apresentado e o novo estado mantém-se após a operação ser concluída. |
| RF-06 | O sistema deve permitir remover uma tarefa. | Depois da confirmação da operação, a tarefa removida deixa de constar na lista. |
| RF-07 | O sistema deve informar o utilizador sobre o resultado das operações. | Operações concluídas ou falhadas apresentam feedback compreensível, sem expor detalhes técnicos sensíveis. |

## 6. Requisitos não funcionais

| ID | Requisito | Critério de aceitação |
| --- | --- | --- |
| RNF-01 | A interface deve adaptar-se a ecrãs de computador e dispositivos móveis. | Conteúdo e ações principais permanecem utilizáveis sem sobreposição ou deslocamento horizontal da página. |
| RNF-02 | As ações principais devem poder ser utilizadas por teclado. | Campos e controlos têm foco visível e podem ser alcançados e acionados por teclado. |
| RNF-03 | A interface deve usar rótulos e mensagens claros, em português. | Controlos e erros podem ser compreendidos sem depender apenas de cor ou ícones. |
| RNF-04 | A aplicação deve validar entradas no cliente e no servidor quando aplicável. | Dados inválidos não são aceites como tarefas válidas, mesmo quando a validação do cliente é contornada. |
| RNF-05 | Dados de tarefas não devem ser divulgados a utilizadores não autorizados. | O acesso aos dados respeita os mecanismos de autorização efetivamente configurados. |
| RNF-06 | A aplicação deve tratar falhas de rede ou de serviço sem perder silenciosamente as alterações. | O utilizador recebe feedback e pode tentar novamente quando a operação não for concluída. |

## 7. Interfaces e dados

- **Interface de utilizador:** páginas web com lista de tarefas, formulário e controlos para editar, concluir e remover.
- **Interface de serviço:** endpoints ou ações de servidor, caso existam, devem validar os dados e comunicar resultados de forma consistente.
- **Dados mínimos de uma tarefa:** identificador único, descrição e estado de conclusão. Datas, prioridade e outros campos não são requisitos desta versão.
- **Persistência:** o mecanismo e a duração de armazenamento devem ser documentados de acordo com a implementação real; não se presume armazenamento permanente.

## 8. Pressupostos, dependências e restrições

- O projeto utiliza Next.js e as dependências definidas nos ficheiros de configuração do repositório.
- A disponibilidade e persistência das tarefas dependem do serviço de dados configurado.
- Autenticação, regras de propriedade dos dados e estratégia de cópias de segurança precisam de especificação própria se forem necessárias.

## 9. Verificação e aceitação

Cada requisito deve ser verificado por teste adequado: testes funcionais para RF-01 a RF-07, testes de interface e acessibilidade para RNF-01 a RNF-03 e testes de validação, autorização e falhas para RNF-04 a RNF-06. A versão é aceite quando os critérios aplicáveis forem satisfeitos e as limitações conhecidas estiverem documentadas.

## 10. Execução em desenvolvimento

Instale as dependências e inicie o servidor:

```bash
npm install
npm run dev
```

Abra [http://localhost:3000](http://localhost:3000) no navegador. Consulte os scripts e as variáveis de ambiente documentados no projeto para instruções adicionais.

## 11. Rotas da API (EndPoints)

### Backend (Next.js API Routes)

- `GET /api/todos`: retorna todas as tarefas;
- `POST /api/todos`: cria uma nova tarefa;
- `PUT /api/todos/[id]`: atualiza uma tarefa existente;
- `DELETE /api/todos/[id]`: remove uma tarefa.
