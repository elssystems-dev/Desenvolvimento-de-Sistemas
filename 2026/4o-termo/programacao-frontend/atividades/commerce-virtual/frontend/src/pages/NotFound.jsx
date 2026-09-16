import { Link } from 'react-router-dom';

export function NotFound() {
  return (
    <div className="page-container not-found">
      <h2>404 - Página Não Encontrada</h2>
      <p>A rota que você tentou acessar não existe.</p>
      <Link to="/" className="btn-primary">
        Voltar para a Página Inicial
      </Link>
    </div>
  );
}