// retrona informações sobre as manutenções 

function ManutencaoFeedback({ isLoading, error, orderCount, onResetStorage }) {
    if (isLoading) {
        return (
            <div className="feedback-container loading" role="status">
                <div className="spinner" aria-hidden="true"></div>
                <p>Carregando ordens de manutenção...</p>
            </div>
        );
    }

    if (error) {
        return (
            <div className="feedback-container error" role="alert">
                <p> Ocorreu uma falha ao sincronizar seus dados: {error}</p>
                <button type="button" onClick={onResetStorage} className="btn-repair">
                    Restaurar Dados e Limpar Cache
                </button>
            </div>
        );
    }

    if (orderCount === 0) {
        return (
            <div className="feedback-container empty">
                <p className="empty-icon">🔧</p>
                <h3>Nenhuma ordem concluída</h3>
                <p>Informe o equipamento e o serviço para iniciar o registro de uma intervenção.</p>
            </div>
            );
    }

    return null;

}

export default ManutencaoFeedback;