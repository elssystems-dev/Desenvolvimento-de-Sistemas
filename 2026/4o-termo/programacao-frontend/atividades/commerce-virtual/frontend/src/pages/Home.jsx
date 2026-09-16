import { Link } from 'react-router-dom';

export function Home() {
  return (
    <div className="page-container">
      <h2>Bem-vindo ao ProdFácil</h2>
      <p>Gerencie seus produtos, acompanhe o catálogo e faça edições em tempo real.</p>
      <div className="cta-actions">
        <Link to="/produtos" className="btn-primary">
          Ver Produtos
        </Link>
      </div>
    </div>
  );
}