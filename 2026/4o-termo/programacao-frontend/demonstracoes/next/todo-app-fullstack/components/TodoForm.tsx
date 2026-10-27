"use client";// significa que é interface cliente side

import { useState, FormEvent } from "react";

interface TodoFormProps {
  onAdd: (title: string) => Promise<void>;
  isLoading: boolean;
}

// Formulario acessivel para adicionar novas tarefas
export default function TodoForm({ onAdd, isLoading }: TodoFormProps) {
  const [title, setTitle] = useState("");
  const [errorMessage, setErrorMessage] = useState("");

  async function handleSubmit(event: FormEvent) {
    event.preventDefault();
    if (title.trim().length < 3) {
      setErrorMessage("O título deve ter pelo menos 3 caracteres.");
      return;
    }

    try {
      setErrorMessage("");
      await onAdd(title.trim());
      setTitle("");
    } catch (err: any) {
      setErrorMessage(err.message || "Erro ao salvar tarefa.");
    }
  }

  return (
    <form className="todo-form" onSubmit={handleSubmit}>
      <div className="input-group">
        <label htmlFor="todo-input" className="sr-only">Nova tarefa</label>
        <input
          id="todo-input"
          type="text"
          placeholder="Ex: Revisar documentação da API..."
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          disabled={isLoading}
        />
        <button type="submit" disabled={isLoading || !title.trim()}>
          {isLoading ? "Salvando..." : "Cadastrar"}
        </button>
      </div>
      {errorMessage && <span className="form-error">{errorMessage}</span>}
    </form>
  );
}