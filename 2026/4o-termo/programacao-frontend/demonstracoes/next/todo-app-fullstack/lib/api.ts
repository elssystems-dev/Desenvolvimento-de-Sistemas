import { ITodoItem } from "@/types/todo";

const BASE_URL = "/api/todos";

// Busca todas as tarefas da API
export async function fetchTodos(): Promise<ITodoItem[]> {
  const response = await fetch(BASE_URL, { cache: "no-store" });
  const result = await response.json();
  if (!result.success) throw new Error(result.error);
  return result.data;
}

// Envia uma nova tarefa para ser salva no servidor
export async function createTodo(title: string): Promise<ITodoItem> {
  const response = await fetch(BASE_URL, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ title })
  });
  const result = await response.json();
  if (!result.success) throw new Error(result.error);
  return result.data;
}

// Atualiza o estado de conclusao da tarefa
export async function toggleTodo(id: string, completed: boolean): Promise<ITodoItem> {
  const response = await fetch(`${BASE_URL}/${id}`, {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ completed })
  });
  const result = await response.json();
  if (!result.success) throw new Error(result.error);
  return result.data;
}

// Solicita a exclusao da tarefa no servidor
export async function deleteTodo(id: string): Promise<void> {
  const response = await fetch(`${BASE_URL}/${id}`, { method: "DELETE" });
  const result = await response.json();
  if (!result.success) throw new Error(result.error);
}