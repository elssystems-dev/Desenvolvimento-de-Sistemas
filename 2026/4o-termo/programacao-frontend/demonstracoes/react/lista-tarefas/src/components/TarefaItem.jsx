import TarefaAction from "./TarefaAction"

// Renderiza o cartão individual de cada tarefa da lista de tarefas com valores personalizados
function TarefaItem({id, titulo, descricao, prioridade = "Média", concluido = false, mudar, remover}) {
    const statusLabel =  concluido ? "Concluída" : "Pendente";

    return(
        <article className="tarefa-item">
            <header className="tarefa-header">
               <h3>{titulo}</h3>
               <span className="tarefa-badge">{prioridade}</span>
            </header>
        <p className="tarefa-desc">{descricao}</p>
        <TarefaAction
            aoCompletar={() => mudar(id)}
            aoRemover={() => remover(id)}
        />
        <footer className="tarefa-footer">
            <small>Status: {statusLabel}</small>
        </footer>
        </article>
    );
}

export default TarefaItem;
