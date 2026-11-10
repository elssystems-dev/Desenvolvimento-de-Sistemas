<div class="card">
    <div style="display:flex; justify-content:space-between; align-items:center;">
        <h2><?= htmlspecialchars($titulo) ?></h2>
        <a href="/tutores/novo" class="btn btn-success">+ Cadastrar Tutor</a>
    </div>

    <!-- Recurso de Busca por Termo -->
    <form action="/tutores" method="GET" style="margin-top:20px; display:flex; gap:10px;">
        <input type="text" name="q" value="<?= htmlspecialchars($busca ?? '') ?>" placeholder="Pesquise por nome, e-mail ou telefone..." style="flex:1;">
        <button type="submit" class="btn">Buscar</button>
        <?php if (!empty($busca)): ?>
            <a href="/tutores" class="btn btn-danger" style="text-decoration:none;">Limpar</a>
        <?php endif; ?>
    </form>

    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Nome do Tutor</th>
                <th>CPF (Protegido LGPD)</th>
                <th>Telefone</th>
                <th>E-mail</th>
                <th style="text-align:right;">Ações</th>
            </tr>
        </thead>
        <tbody>
            <?php if (empty($tutores)): ?>
                <tr><td colspan="6" style="text-align:center; color:#94a3b8;">Nenhum tutor encontrado para o termo pesquisado.</td></tr>
            <?php else: ?>
                <?php foreach ($tutores as $t): ?>
                    <tr>
                        <td>#<?= (int)$t['id'] ?></td>
                        <td><strong><?= htmlspecialchars($t['nome']) ?></strong></td>
                        <td><code><?= htmlspecialchars($t['cpf']) ?></code></td>
                        <td><?= htmlspecialchars($t['telefone']) ?></td>
                        <td><?= htmlspecialchars($t['email']) ?></td>
                        <td style="text-align:right;">
                            <a href="/tutores/editar?id=<?= (int)$t['id'] ?>" class="btn" style="padding:4px 8px; font-size:0.75rem;">Editar</a>
                        </td>
                    </tr>
                <?php endforeach; ?>
            <?php endif; ?>
        </tbody>
    </table>
</div>