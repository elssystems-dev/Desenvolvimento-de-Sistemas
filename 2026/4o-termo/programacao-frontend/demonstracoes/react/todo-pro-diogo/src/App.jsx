import { useState } from "react";
import TodoForm from "./TodoForm";
import TodoList from "./TodoList";

const App = () => {
  // Inicializar as informações usando useState
  const [tarefas, setTarefas] = useState([]); // Vetor inicial vazio

  // Métodos

  //  addTarefa

  const addTarefa = (texto) => {
    const novaTarefa = {
      id: crypto.randomUUID(), // Gera uma chave aleatória criptografada
      texto,
      completed: false
    }
    setTarefas((tarefasAtuais) => [...tarefasAtuais, novaTarefa]);
  }

  // modificarTarefa
  const modificarTarefa = (id) => {
    setTarefas(
      (tarefasAtuais) => tarefasAtuais.map(
        (tarefa) => tarefa.id === id ? {...tarefa, completed : !tarefa.completed } 
        : tarefa
    ));
  }
  
  // removerTarefa
  const removerTarefa = (id) => {
    setTarefas((tarefasAtuais) => tarefasAtuais.filter((tarefa) => tarefa.id !== id));
  }

  // Virtual DOM
  return (
    <main>
      <h1>Lista de Tarefas Todo-Pro</h1>
      <TodoForm addTarefa={addTarefa}></TodoForm>
      <TodoList tarefas={tarefas} modificarTarefa={modificarTarefa} removerTarefa={removerTarefa}></TodoList>
    </main>
  );
};

export default App;