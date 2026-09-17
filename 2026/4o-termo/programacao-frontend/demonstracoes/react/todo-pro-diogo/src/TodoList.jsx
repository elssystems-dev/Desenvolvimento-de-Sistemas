// Componente para listar todas as tarefas

const TodoList = ({tarefas, modificarTarefa, removerTarefa}) => {
    if (tarefas.length === 0) {
        return <p>Nenhuma tarefa pendente!</p>;
    }

    return (
        <ul>
            {tarefas.map((tarefa) => (
                <li key={tarefa.id}>
                    <span onClick={() => modificarTarefa(tarefa.id)}
                        style={{textDecoration: tarefa.completed ? "line-through" : "none", 
                                cursor: "pointer", color: "black"}}>
                        {tarefa.texto}
                    </span>
                    <button onClick={() => removerTarefa(tarefa.id)}>Excluir</button>
                </li>
            ))}
        </ul>
    );
};

export default TodoList;