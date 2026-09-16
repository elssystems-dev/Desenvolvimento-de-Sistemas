const API_URL = "http://localhost:5000/api/products";

export const getProducts = async () => {
  const response = await fetch(API_URL);
  if (!response.ok) throw new Error("Falha ao carregar produtos.");
  return response.json();
};

export const getProductById = async (id) => {
  const response = await fetch(`${API_URL}/${id}`);
  if (!response.ok) throw new Error("Produto não encontrado.");
  return response.json();
};

export const createProduct = async (produto) => {
  const response = await fetch(API_URL, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(produto),
  });
  if (!response.ok) throw new Error("Erro ao criar produto.");
  return response.json();
};

export const updateProduct = async (id, produto) => {
  const response = await fetch(`${API_URL}/${id}`, {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(produto),
  });
  if (!response.ok) throw new Error("Erro ao atualizar produto.");
  return response.json();
};

export const deleteProduct = async (id) => {
  const response = await fetch(`${API_URL}/${id}`, { method: "DELETE" });
  if (!response.ok) throw new Error("Erro ao excluir produto.");
  return response.json();
};
