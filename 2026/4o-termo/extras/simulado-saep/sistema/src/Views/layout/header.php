<?php
    $usuarioLogado = $_SESSION['usuario_nome'] ?? null;
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= htmlspecialchars($titulo ?? 'VetCare — Clínica Veterinária') ?></title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #0f172a; margin: 0; color: #f8fafc; }
        header { background: #1e293b; padding: 14px 28px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #334155; }
        header h1 { font-size: 1.15rem; color: #38bdf8; margin: 0; }
        nav { display: flex; align-items: center; gap: 15px; }
        nav a { color: #94a3b8; text-decoration: none; font-weight: 600; font-size: 0.9rem; }
        nav a:hover { color: #38bdf8; }
        .user-tag { background: #0f172a; padding: 5px 12px; border-radius: 20px; font-size: 0.85rem; border: 1px solid #334155; color: #38bdf8; }
        .container { max-width: 1050px; margin: 30px auto; padding: 0 20px; }
        .card { background: #1e293b; border-radius: 8px; padding: 25px; border: 1px solid #334155; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.3); }
        .grid-stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 15px; margin-top: 20px; }
        .stat-box { background: #0f172a; padding: 18px; border-radius: 6px; text-align: center; border: 1px solid #334155; }
        .stat-box span { font-size: 0.8rem; color: #94a3b8; text-transform: uppercase; font-weight: bold; }
        .stat-box strong { display: block; font-size: 1.8rem; color: #38bdf8; margin-top: 8px; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; font-size: 0.88rem; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #334155; }
        th { color: #94a3b8; font-weight: 600; background: #0f172a; }
        .btn { display: inline-block; background: #0284c7; color: white; padding: 8px 14px; border-radius: 5px; text-decoration: none; font-weight: bold; font-size: 0.85rem; border: none; cursor: pointer; }
        .btn:hover { background: #0369a1; }
        .btn-success { background: #059669; }
        .btn-success:hover { background: #047857; }
        .btn-danger { background: #dc2626; }
        .btn-danger:hover { background: #b91c1c; }
        .form-group { margin-bottom: 16px; }
        label { display: block; font-size: 0.85rem; margin-bottom: 6px; color: #cbd5e1; font-weight: 600; }
        input, select, textarea { width: 100%; padding: 10px; border-radius: 5px; border: 1px solid #475569; background: #0f172a; color: #f8fafc; box-sizing: border-box; }
        .alerta-erro { background: #7f1d1d; border: 1px solid #dc2626; color: #fecaca; padding: 10px; border-radius: 5px; margin-bottom: 15px; font-size: 0.85rem; }
    </style>
</head>
<body>
<header>
    <h1>SisVet — Gestão Veterinária</h1>
    <nav>
        <?php if ($usuarioLogado): ?>
            <a href="/">Painel</a>
            <a href="/tutores">Tutores</a>
            <a href="/pets">Pets</a>
            <a href="/agendamentos">Agendamentos</a>
            <span class="user-tag">👤 <?= htmlspecialchars($usuarioLogado) ?></span>
            <form action="/logout" method="POST" style="display:inline;margin:0;">
                <button type="submit" class="btn btn-danger" style="padding:5px 10px;font-size:0.8rem;">Sair</button>
            </form>
        <?php else: ?>
            <a href="/login" class="btn">Entrar</a>
        <?php endif; ?>
    </nav>
</header>
<div class="container">