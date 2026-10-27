"use client";

import { useState, useEffect } from "react";
import { ITodoItem } from "@/types/todo";
import { fetchTodos, createTodo, toggleTodo, deleteTodo } from "@/lib/api";
import TodoForm from "@/components/TodoForm";
import TodoList from "@/components/TodoList";

export default function HomePage() {
  const [todos, setTodos] = useState<ITodoItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  // Carrega as tarefas salvas na montagem da pagina
  useEffect(() => {
    loadTodos();
  }, []);

  async function loadTodos() {
    try {
      setLoading(true);
      const data = await fetchTodos();
      setTodos(data);
      setErrorMessage(null);
    } catch (err: any) {
      setErrorMessage("Não foi possível carregar as tarefas do servidor.");
    } finally {
      setLoading(false);
    }
  }

  async function handleAddTodo(title: string) {
    setActionLoading(true);
    try {
      const created = await createTodo(title);
      setTodos((prev) => [created, ...prev]);
    } finally {
      setActionLoading(false);
    }
  }

  async function handleToggleTodo(id: string, completed: boolean) {
    const updated = await toggleTodo(id, completed);
    setTodos((prev) => prev.map((item) => (item._id === id ? updated : item)));
  }

  async function handleDeleteTodo(id: string) {
    await deleteTodo(id);
    setTodos((prev) => prev.filter((item) => item._id !== id));
  }

  return (
    <main className="container">
      <header className="page-header">
        <div className="badge">Next.js + MongoDB</div>
        <h1>To-Do Pro Fullstack</h1>
        <p>Persistência em banco de dados NoSQL com App Router</p>
      </header>

      {errorMessage && (
        <div className="alert-error" role="alert">
          <span>{errorMessage}</span>
          <button type="button" onClick={loadTodos}>Tentar novamente</button>
        </div>
      )}

      <TodoForm onAdd={handleAddTodo} isLoading={actionLoading} />
      <TodoList
        todos={todos}
        isLoading={loading}
        onToggle={handleToggleTodo}
        onDelete={handleDeleteTodo}
      />
    </main>
  );
}