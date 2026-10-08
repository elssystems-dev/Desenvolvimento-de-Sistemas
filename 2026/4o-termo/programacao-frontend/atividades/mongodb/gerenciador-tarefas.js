// EXERCÍCIO 1 - Criação de Banco de Dados e Coleção
// Cria e seleciona o banco de dados gerenciadorDeTarefas
use("gerenciadorDeTarefas");


// EXERCÍCIO 2 - Inserção de Tarefas (CREATE)
// Insere as três tarefas iniciais na coleção tarefas
db.getCollection("tarefas").insertMany([
  {
    titulo: "Comprar Leite",
    descricao: "Leite integral no supermercado",
    status: "pendente",
    prioridade: "alta",
    dataLimite: "2023-10-26"
  },
  {
    titulo: "Preparar Apresentação",
    descricao: "Slides para a reunião de segunda",
    status: "em andamento",
    prioridade: "alta",
    dataLimite: "2023-10-30"
  },
  {
    titulo: "Responder E-mails",
    descricao: "Limpar a caixa de entrada",
    status: "pendente",
    prioridade: "média",
    dataLimite: "2023-10-27"
  }
]);


// EXERCÍCIO 3 - Leitura de Tarefas (READ)
// Lista todas as tarefas presentes na coleção
db.getCollection("tarefas").find({});

// Lista somente as tarefas com status "pendente"
db.getCollection("tarefas").find({
  status: "pendente"
});

// Lista as tarefas com prioridade "alta"
// Exibe somente titulo e dataLimite
// _id: 0 exclui o identificador automático
db.getCollection("tarefas").find(
  { prioridade: "alta" },
  { titulo: 1, dataLimite: 1, _id: 0 }
);


// EXERCÍCIO 4 - Atualização de Tarefas (UPDATE)
// Atualiza o status da tarefa "Comprar Leite"
db.getCollection("tarefas").updateOne(
  { titulo: "Comprar Leite" },
  { $set: { status: "concluída" } }
);

// Altera a prioridade de "Responder E-mails"
// e adiciona o campo responsavel
db.getCollection("tarefas").updateOne(
  { titulo: "Responder E-mails" },
  {
    $set: {
      prioridade: "baixa",
      responsavel: "Seu Nome"
    }
  }
);

// Adiciona a nova tarefa "Estudar MongoDB"
db.getCollection("tarefas").insertOne({
  titulo: "Estudar MongoDB",
  descricao: "Revisar comandos CRUD e agregação",
  status: "pendente",
  prioridade: "alta",
  dataLimite: "2023-11-05"
});

// Atualiza todas as tarefas que estão pendentes
// adicionando o campo tag com o valor "urgente"
db.getCollection("tarefas").updateMany(
  { status: "pendente" },
  { $set: { tag: "urgente" } }
);


// EXERCÍCIO 5 - Deletar Tarefas (DELETE)
// Deleta a tarefa com o título "Comprar Leite"
db.getCollection("tarefas").deleteOne({
  titulo: "Comprar Leite"
});

// Deleta todas as tarefas que possuem prioridade "baixa"
db.getCollection("tarefas").deleteMany({
  prioridade: "baixa"
});


// EXERCÍCIO 6 - Consultas Avançadas e Agregação

// Insere mais algumas tarefas
db.getCollection("tarefas").insertMany([
  {
    titulo: "Planejar Viagem",
    descricao: "Pesquisar destinos",
    status: "pendente",
    prioridade: "média",
    dataLimite: "2024-01-15"
  },
  {
    titulo: "Pagar Contas",
    descricao: "Contas de água e luz",
    status: "em andamento",
    prioridade: "alta",
    dataLimite: "2023-10-28"
  },
  {
    titulo: "Fazer Exercício",
    descricao: "Academia ou caminhada",
    status: "pendente",
    prioridade: "baixa",
    dataLimite: "2023-10-26"
  }
]);

// Lista as tarefas que têm status "pendente"
// OU prioridade "alta"
db.getCollection("tarefas").find({
  $or: [
    { status: "pendente" },
    { prioridade: "alta" }
  ]
});

// Cria um índice no campo dataLimite
db.getCollection("tarefas").createIndex({
  dataLimite: 1
});

// Conta quantas tarefas existem para cada status
db.getCollection("tarefas").aggregate([
  {
    $group: {
      _id: "$status",
      total: { $sum: 1 }
    }
  }
]);

// Encontra a tarefa pendente mais urgente
// Ordena dataLimite em ordem crescente e pega somente a primeira
db.getCollection("tarefas").find({
  status: "pendente"
}).sort({
  dataLimite: 1
}).limit(1);