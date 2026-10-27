"use client";

import { ITodoItem } from "@/types/todo";
import TodoItem from "./TodoItem";

interface TodoListProps {
  todos: ITodoItem[];
  isLoading: boolean;
  onToggle: (id: string, completed: boolean) => void;
  onDelete: (id: string) => void;
}

// Renderiza a lista de tarefas tratando estados de carregamento e lista vazia
export default function TodoList({ todos, isLoading, onToggle, onDelete }: TodoListProps) {
  if (isLoading) {
    return (
      <div className="state-feedback" role="status">
        <div className="spinner" aria-hidden="true"></div>
        <p>Carregando tarefas do banco de dados...</p>
      </div>
    );
  }

  if (todos.length === 0) {
    return (
      <div className="state-feedback empty">
        <p className="empty-icon">📝</p>
        <h3>Nenhuma tarefa cadastrada</h3>
        <p>Utilize o campo acima para registrar sua primeira tarefa no MongoDB.</p>
      </div>
    );
  }

  return (
    <ul className="todo-list" aria-label="Lista de tarefas cadastradas">
      {todos.map((todo) => (
        <TodoItem key={todo._id} todo={todo} onToggle={onToggle} onDelete={onDelete} />
      ))}
    </ul>
  );
}