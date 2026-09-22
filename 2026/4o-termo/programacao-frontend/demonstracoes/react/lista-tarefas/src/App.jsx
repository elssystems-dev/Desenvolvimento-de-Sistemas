import Header from "./components/Header"
import TarefaForm from "./components/TarefaForm";
import TarefaItem from "./components/TarefaItem";
import TarefaList from "./components/TarefaList";
import { tarefasIniciais } from "./data/tarefaMock";

function App() {

    function handleMudar(id) {
        console.log("Alterar status da tarefa", id);
    }

    function handleRemover(id) {
        console.log("Remover tarefa", id);
    }

    function handleAdicionar(titulo) {
        console.log("Adicionar nova tarefa", titulo)
    }

    return(
        <main className="app-container">
            <Header/>
            <section className="app-content">
                <TarefaForm aoAdicionarTarefa={handleAdicionar}/>
                <TarefaList
                    tarefas={tarefasIniciais}
                    aoMudarTarefa={handleMudar}
                    aoRemoverTarefa={handleRemover}
                />
            </section>
        </main>
    );
}

export default App;