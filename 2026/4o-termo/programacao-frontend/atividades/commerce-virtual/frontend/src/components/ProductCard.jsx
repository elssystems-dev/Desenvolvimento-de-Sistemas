import { Link } from 'react-router-dom';

export function ProductCard({ id, nome, preco, categoria, onRemover, onEditar }) {
  return (
    <article className="product-card">
      <h4>{nome}</h4>
      <p>R$ {preco.toFixed(2)}</p>
      <span className="tag">{categoria}</span>
      <div className="card-actions">
        <Link to={`/produtos/${id}`} className="btn-details">
          Detalhes
        </Link>
        <button type="button" onClick={onEditar} className="btn-edit">
          Editar
        </button>
        <button type="button" onClick={onRemover} className="btn-delete">
          Excluir
        </button>
      </div>
    </article>
  );
}