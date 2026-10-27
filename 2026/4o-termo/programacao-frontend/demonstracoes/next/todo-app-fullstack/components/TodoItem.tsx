"use client";

import { ITodoItem } from "@/types/todo";

interface TodoItemProps {
  todo: ITodoItem;
  onToggle: (id: string, completed: boolean) => void;
  onDelete: (id: string) => void;
}

// Card individual da tarefa com alternancia e exclusao
export default function TodoItem({ todo, onToggle, onDelete }: TodoItemProps) {
  const formattedDate = new Date(todo.createdAt).toLocaleDateString("pt-BR", {
    day: "2-digit",
    month: "2-digit",
    hour: "2-digit",
    minute: "2-digit"
  });

  return (
    <li className={`todo-item ${todo.completed ? "completed" : ""}`}>
      <label className="checkbox-container">
        <input
          type="checkbox"
          checked={todo.completed}
          onChange={() => onToggle(todo._id, !todo.completed)}
          aria-label={`Marcar ${todo.title} como ${todo.completed ? "pendente" : "concluída"}`}
        />
        <span className="todo-title">{todo.title}</span>
      </label>
      <div className="item-actions">
        <time className="todo-date">{formattedDate}</time>
        <button
          type="button"
          className="btn-delete"
          onClick={() => onDelete(todo._id)}
          aria-label={`Excluir tarefa ${todo.title}`}
        >
          Excluir
        </button>
      </div>
    </li>
  );
}