import { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { getProductById } from '../services/api';

export function DetalheProduto() {
  const { id } = useParams();
  const [produto, setProduto] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchProduto = async () => {
      try {
        setIsLoading(true);
        const dados = await getProductById(id);
        setProduto(dados);
      } catch (err) {
        setError(err.message);
      } finally {
        setIsLoading(false);
      }
    };

    fetchProduto();
  }, [id]);

  if (isLoading) return <p className="status-message loading">Carregando detalhes...</p>;
  if (error) return <p className="status-message error">{error}</p>;

  return (
    <div className="page-container product-detail">
      <Link to="/produtos" className="btn-back">
        ← Voltar aos Produtos
      </Link>
      <h2>{produto.nome}</h2>
      <p className="price">Preço: R$ {produto.preco.toFixed(2)}</p>
      <p className="category">Categoria: {produto.categoria}</p>
      <p className="description">{produto.descricao || 'Sem descrição informada.'}</p>
    </div>
  );
}