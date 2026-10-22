//Formulário de cadastro de nova tarefas com semantica de acessibilidade

import { useState } from "react";

function TarefaForm({ aoAddTarefa }) {

    // adicionando os useState
    const [titulo, setTitulo] = useState("");
    const [error, setError] = useState("");


    function handleSubmit(e){
        e.preventDefault();

        //verificar se o título da tarefa é válido
        if(titulo.trim().length < 4){
            setError("O títlo da tarefa deve ter pelo menos 4 caracteres");
            return;
        }

        //Simular a criação de Tarefa
        aoAddTarefa(titulo.trim());// adiciona o titulo a função de callback 
        setError("");//limpa os campos de erro e titulo
        setTitulo("");
    }

    return(
        <form className="tarefa-form" onSubmit={handleSubmit}>
            <div className="form-group">
                <input 
                    type="text" 
                    placeholder="Digite o título da Tarefa"
                    value = {titulo}
                    onChange={(e) => setTitulo(e.target.value)} 
                />
                <button type="submit" className="btn-add">Adicionar</button>
            </div>
            {error && <p className="error-message">{error}</p>}
            
        </form>
    );
}

export default TarefaForm;