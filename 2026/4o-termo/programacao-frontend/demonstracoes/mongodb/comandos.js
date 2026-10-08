use("Eduardodb");

db.getCollection("Eduardodb").insertMany([
  {
    titulo: "O Senhor dos Anéis",
    autor: "J.R.R. Tolkien",
    ano: 1954,
    genero: "Fantasia",
    paginas: 1178,
    disponivel: true,
  },
  {
    titulo: "1984",
    autor: "George Orwell",
    ano: 1949,
    genero: "Distopia",
    paginas: 328,
    disponivel: true,
  },
  {
    titulo: "Dom Quixote",
    autor: "Miguel de Cervantes",
    ano: 1605,
    genero: "Clássico",
    paginas: 863,
    disponivel: false,
  },
  {
    titulo: "O Pequeno Príncipe",
    autor: "Antoine de Saint-Exupéry",
    ano: 1943,
    genero: "Ficção Infantil",
    paginas: 96,
    disponivel: true,
  },
  {
    titulo: "O Guia do Mochileiro das Galáxias",
    autor: "Douglas Adams",
    ano: 1979,
    genero: "Ficção Científica",
    paginas: 193,
    disponivel: true,
  },
  {
    titulo: "Cem Anos de Solidão",
    autor: "Gabriel García Márquez",
    ano: 1967,
    genero: "Realismo Mágico",
    paginas: 417,
    disponivel: false,
  },
]);

//Passo 1 - Consultas com filtro: Livros publicados após 1950 e que estão disponíveis
db.getCollection("Eduardodb").find({ ano: {$gt: 1950}, disponivel: true});

//Passo 2 - find - todos livros que tem menos de 200 páginas
db.getCollection("Eduardodb").find({ paginas: { $lt: 200 }});

//Passo 3- find exiba: título, autor e ano dos livros, excluindo o id
db.getCollection("Eduardodb").find({}, {titulo:1, autor:1, ano:1, _id:0});

//Passo 4 - Atualização - Mudar o gênero: "Distopia" => "Ficção Distópica"
db.getCollection("Eduardodb").updateMany({genero: "Distopia"}, {$set: {genero: "Ficção Distópica"}});

// Passo 5 - Todo livro que tiver + de 500 páginas - ganhe uma chave { edicao: "Longa"}
db.getCollection("Eduardodb").updateMany({paginas: {$gt: 500}}, {$set: {edicao: "Longa"}})