// Componente para renderização do formulário de novas tarefas

import { useState } from "react";

const TodoForm = ({addTarefa}) => {

    // const garante que o valor não mude o valor da variável de estado
    // toda alteração de valor deve acontecer pelo "set"
    // a cada nova renderização o valor novo é atribuido de estado 1º elemento do vetor

    const [textoTarefa, setTextoTarefa] = useState(""); // Variável de estado no React

    // Evento para enviar do formulário
    const handleSubmit = (e) => {
        e.preventDefault(); // Evita o recarregamento da página
        if (!textoTarefa.trim()) return; // Se textoTarefa for vazio, interrompe o fluxo

        addTarefa(textoTarefa.trim());
        setTextoTarefa(""); // Limpa o campo da tarefa após adicionar a tarefa
    };

    // Virtual DOM
    return (
        <form onSubmit={handleSubmit}>
            <input 
                type="text" 
                placeholder="Digite uma nova tarefa"
                value={textoTarefa}
                onChange={(e) => setTextoTarefa(e.target.value)}
            />
            <button type="submit">Adicionar</button>
        </form>
    );
}

export default TodoForm;