import { Routes, Route } from 'react-router-dom';
import { Header } from './components/Header';
import { Home } from './pages/Home';
import { Produtos } from './pages/Produtos';
import { DetalheProduto } from './pages/DetalheProduto';
import { Sobre } from './pages/Sobre';
import { NotFound } from './pages/NotFound';

export default function App() {
  return (
    <>
      <Header />
      <main id="main-content">
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/produtos" element={<Produtos />} />
          <Route path="/produtos/:id" element={<DetalheProduto />} />
          <Route path="/sobre" element={<Sobre />} />
          {/* Rota coringa (*) para capturar caminhos não mapeados */}
          <Route path="*" element={<NotFound />} />
        </Routes>
      </main>
    </>
  );
}