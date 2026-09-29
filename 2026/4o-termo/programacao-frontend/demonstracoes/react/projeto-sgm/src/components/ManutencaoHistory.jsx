//Listar Ordens de Manutenção (Concluidas e Duração)

function ManutencaoHistory({ ordens = [], onClearHistory }) {
    if (ordens.length === 0) return null;


    return (
        <section className="history-section" aria-labelledby="history-title">
            <div className="history-header">
                <h2 id="history-title">Ordens de manutenção concluídas ({ordens.length})</h2>
                <button
                    type="button"
                    className="btn-clear"
                    onClick={onClearHistory}
                    aria-label="Limpar histórico de ordens concluídas"
                >
                    Limpar histórico
                </button>
            </div>

            <ul className="history-list">
                {ordens.map((item) => (
                    <li key={item.id} className="history-card">
                        <div className="card-info">
                            <strong>{item.equipment}</strong>
                            <span className="badge-mode">{item.service}</span>
                        </div>
                        <span>{Math.floor(item.durationSeconds / 60)} min</span>
                        <time className="card-time">{item.completedAt}</time>
                    </li>
                ))}
            </ul>
        </section>
    );
}

export default ManutencaoHistory;
