// Método para controlar as ações das tarefas via callback

function TarefaAction({aoCompletar, aoRemover}) {
    return (
        <div className="tarefa-action">
            <button type="button" className="btn-done" onClick={aoCompletar}>
                Concluir
            </button>
            <button type="button" className="btn-delete" onClick={aoRemover}>
                Deletar
            </button>
        </div>
    );
}

export default TarefaAction;