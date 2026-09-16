import { NavLink } from 'react-router-dom';

export function Header() {
  return (
    <header className="main-header">
      <div className="header-container">
        <h1>ProdFácil</h1>
        <nav aria-label="Navegação principal">
          <ul className="nav-list">
            <li>
              <NavLink to="/" className={({ isActive }) => (isActive ? 'active' : '')}>
                Home
              </NavLink>
            </li>
            <li>
              <NavLink to="/produtos" className={({ isActive }) => (isActive ? 'active' : '')}>
                Produtos
              </NavLink>
            </li>
            <li>
              <NavLink to="/sobre" className={({ isActive }) => (isActive ? 'active' : '')}>
                Sobre
              </NavLink>
            </li>
          </ul>
        </nav>
      </div>
    </header>
  );
}