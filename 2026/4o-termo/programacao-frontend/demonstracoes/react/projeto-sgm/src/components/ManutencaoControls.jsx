// Iniciar , pausar  concluir  e zerar uma ordem de manutenção

function ManutecaoControls({isActive, onToggle, onReset, onComplete, canStart, canComplete}){
    return(
        <div className="controls-group">
            <button type="button" 
            className={`btn-primary ${isActive ? "btn-pause" : "btn-start"}`} 
            onClick={onToggle} 
            disabled={!isActive && !canStart} 
            aria-label={isActive ?  "Pausar ordem de manutenção" : "Iniciar Ordem Manutenção"}>
                {isActive ? "Pausar" : "Iniciar"}
            </button>

            <button type="button"
            className="btn-secondary"
            onClick={onReset}
            aria-label="Zera o tempo da ordem de Manutenção">
                Zerar
            </button>

            <button 
            type="button" 
            className=" btn-secondary" 
            onClick={onComplete} 
            disabled={!canComplete}> 
                Concluir Ordem
            </button>
        </div>
    );
}

export default ManutecaoControls;