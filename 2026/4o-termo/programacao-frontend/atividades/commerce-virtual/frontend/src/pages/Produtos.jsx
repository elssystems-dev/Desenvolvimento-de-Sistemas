import { useState, useEffect } from 'react';
import { ProductForm } from '../components/ProductForm';
import { ProductCard } from '../components/ProductCard';
import { getProducts, createProduct, updateProduct, deleteProduct } from '../services/api';

export function Produtos() {
  const [produtos, setProdutos] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');
  const [produtoEmEdicao, setProdutoEmEdicao] = useState(null);

  const carregarProdutos = async () => {
    try {
      setIsLoading(true);
      setError('');
      const dados = await getProducts();
      setProdutos(dados);
    } catch (err) {
      setError(err.message);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    carregarProdutos();
  }, []);

  const handleSalvar = async (dados) => {
    try {
      if (produtoEmEdicao) {
        await updateProduct(produtoEmEdicao.id, dados);
      } else {
        await createProduct(dados);
      }
      setProdutoEmEdicao(null);
      carregarProdutos();
    } catch (err) {
      alert(err.message);
    }
  };

  const handleRemover = async (id) => {
    try {
      await deleteProduct(id);
      carregarProdutos();
    } catch (err) {
      alert(err.message);
    }
  };

  return (
    <div className="page-container">
      <ProductForm
        key={produtoEmEdicao ? produtoEmEdicao.id : 'novo'}
        onSalvarProduto={handleSalvar}
        produtoEmEdicao={produtoEmEdicao}
        onCancelarEdicao={() => setProdutoEmEdicao(null)}
      />

      {isLoading && <p className="status-message loading">Carregando...</p>}
      {error && <p className="status-message error">{error}</p>}

      {!isLoading && !error && (
        <section className="catalog">
          {produtos.map((p) => (
            <ProductCard
              key={p.id}
              {...p}
              onRemover={() => handleRemover(p.id)}
              onEditar={() => setProdutoEmEdicao(p)}
            />
          ))}
        </section>
      )}
    </div>
  );
}