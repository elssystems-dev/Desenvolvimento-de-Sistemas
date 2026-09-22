// Formulário de cadastro de novas tarefas com semântica de acessibilidade

function TarefaForm({aoAdicionarTarefa}){
    function handleSubmit(e){
        e.preventDefault();
        // Simular a criação de tarefa
        aoAdicionarTarefa("Nova tarefa adicionada!")
    }

    return(
        <form className="tarefa-form" onSubmit={handleSubmit}>
            <label htmlFor="tarefa-titulo">Título</label>
            <div className="input-group">
                <input 
                    id="tarefa-titulo"
                    type="text"
                    placeholder="Ex.: Revisar documentação"
                    required
                />
                <button type="submit" className="btn-primario">Adicionar</button>
            </div>
        </form>
    );
}

export default TarefaForm;