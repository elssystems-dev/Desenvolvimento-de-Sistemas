<div class="card" style="max-width: 800px; margin: 0 auto;">
    <h2><?= htmlspecialchars($titulo ?? 'Gerenciamento de Pets') ?></h2>

    <a href="/pets/novo" class="btn" style="margin-bottom: 15px; display: inline-block;">+ Novo Pet</a>

    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Nome</th>
                <th>Espécie</th>
                <th>Raça</th>
                <th>Data de Nascimento</th>
            </tr>
        </thead>
        <tbody>
            <?php if (!empty($pets) && is_array($pets)): ?>
                <?php foreach ($pets as $pet): ?>
                    <tr>
                        <td><?= (int)($pet['id'] ?? 0) ?></td>
                        <td><?= htmlspecialchars($pet['nome'] ?? '') ?></td>
                        <td><?= htmlspecialchars($pet['especie'] ?? '') ?></td>
                        <td><?= htmlspecialchars($pet['raca'] ?? '') ?></td>
                        <td><?= htmlspecialchars($pet['data_nascimento'] ?? '') ?></td>
                    </tr>
                <?php endforeach; ?>
            <?php else: ?>
                <tr>
                    <td colspan="5">Nenhum pet cadastrado.</td>
                </tr>
            <?php endif; ?>
        </tbody>
    </table>
</div>