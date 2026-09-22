// Renderizar a lista de tarefas

import TarefaItem from "./TarefaItem";

function TarefaList({tarefas=[], aoMudarTarefa, aoRemoverTarefa}) {
    if(tarefas.length === 0) {
        return <p className="empty">Nenhuma tarefa adicionada</p>
    }

    return (
        <div className="tarefa-grid">
            {tarefas.map((e) => (
                <TarefaItem
                    key={e.id}
                    id={e.id}
                    titulo={e.titulo}
                    concluido={e.concluido}
                    mudar={aoMudarTarefa}
                    remover={aoRemoverTarefa}
                />
            ))}
        </div>
    );
}

export default TarefaList