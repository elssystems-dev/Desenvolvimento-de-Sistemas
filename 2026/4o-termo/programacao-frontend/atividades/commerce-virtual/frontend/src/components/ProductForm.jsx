import { useState } from 'react';

export function ProductForm({ onSalvarProduto, produtoEmEdicao, onCancelarEdicao }) {
  const [nome, setNome] = useState(produtoEmEdicao?.nome || '');
  const [preco, setPreco] = useState(produtoEmEdicao?.preco || '');
  const [categoria, setCategoria] = useState(produtoEmEdicao?.categoria || '');
  const [descricao, setDescricao] = useState(produtoEmEdicao?.descricao || '');
  const [erros, setErros] = useState({});

  const handleLimpar = () => {
    setNome('');
    setPreco('');
    setCategoria('');
    setDescricao('');
    setErros({});
  };

  const validarCampos = () => {
    const novosErros = {};
    if (!nome.trim()) novosErros.nome = 'O campo nome é obrigatório!';
    if (!preco || parseFloat(preco) <= 0) novosErros.preco = 'Informe um preço válido maior que zero.';
    if (!categoria.trim()) novosErros.categoria = 'A categoria é obrigatória.';

    setErros(novosErros);
    return Object.keys(novosErros).length === 0;
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!validarCampos()) return;

    onSalvarProduto({
      nome,
      preco: parseFloat(preco),
      categoria,
      descricao
    });

    handleLimpar();
  };

  return (
    <form onSubmit={handleSubmit} className="form-container" aria-labelledby="form-title">
      <h3 id="form-title">{produtoEmEdicao ? 'Editar Produto' : 'Cadastrar Novo Produto'}</h3>

      <div className="form-group">
        <label htmlFor="nome-input">Nome do Produto *</label>
        <input
          id="nome-input"
          type="text"
          placeholder="Ex: Teclado Mecânico"
          value={nome}
          onChange={(e) => setNome(e.target.value)}
          className={erros.nome ? 'input-error' : ''}
          aria-invalid={!!erros.nome}
          aria-describedby={erros.nome ? 'erro-nome' : undefined}
        />
        {erros.nome && <span id="erro-nome" className="error-message" role="alert">{erros.nome}</span>}
      </div>

      <div className="form-row">
        <div className="form-group">
          <label htmlFor="preco-input">Preço (R$) *</label>
          <input
            id="preco-input"
            type="number"
            step="0.01"
            placeholder="Ex: 199.90"
            value={preco}
            onChange={(e) => setPreco(e.target.value)}
            className={erros.preco ? 'input-error' : ''}
            aria-invalid={!!erros.preco}
            aria-describedby={erros.preco ? 'erro-preco' : undefined}
          />
          {erros.preco && <span id="erro-preco" className="error-message" role="alert">{erros.preco}</span>}
        </div>

        <div className="form-group">
          <label htmlFor="categoria-input">Categoria *</label>
          <input
            id="categoria-input"
            type="text"
            placeholder="Ex: Eletrônicos"
            value={categoria}
            onChange={(e) => setCategoria(e.target.value)}
            className={erros.categoria ? 'input-error' : ''}
            aria-invalid={!!erros.categoria}
            aria-describedby={erros.categoria ? 'erro-categoria' : undefined}
          />
          {erros.categoria && <span id="erro-categoria" className="error-message" role="alert">{erros.categoria}</span>}
        </div>
      </div>

      <div className="form-group">
        <label htmlFor="descricao-input">Descrição</label>
        <textarea
          id="descricao-input"
          placeholder="Escreva uma breve descrição do item..."
          value={descricao}
          onChange={(e) => setDescricao(e.target.value)}
          rows="3"
        />
      </div>

      <div className="form-buttons">
        <button type="submit" className="btn-submit">
          {produtoEmEdicao ? 'Salvar Alterações' : 'Cadastrar Produto'}
        </button>

        {produtoEmEdicao ? (
          <button type="button" onClick={onCancelarEdicao} className="btn-clear">
            Cancelar
          </button>
        ) : (
          <button type="button" onClick={handleLimpar} className="btn-clear">
            Limpar
          </button>
        )}
      </div>
    </form>
  );
}