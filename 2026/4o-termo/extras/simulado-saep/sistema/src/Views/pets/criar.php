<div class="card" style="max-width: 600px; margin: 0 auto;">
    <h2><?= htmlspecialchars($titulo) ?></h2>
    <?php if (!empty($erro)): ?>
        <div class="alerta-erro"><?= htmlspecialchars($erro) ?></div>
    <?php endif; ?>

    <form action="/pets/salvar" method="POST">
        <input type="hidden" name="csrf_token" value="<?= htmlspecialchars($csrfToken ?? '') ?>">
        <div class="form-group">
            <label for="tutor_id">Tutor Responsável (Obrigatório)</label>
            <select id="tutor_id" name="tutor_id" required>
                <option value="">-- Selecione o Tutor --</option>
                <?php foreach ($tutores as $t): ?>
                    <option value="<?= (int)$t['id'] ?>"><?= htmlspecialchars($t['nome']) ?> (<?= htmlspecialchars($t['telefone']) ?>)</option>
                <?php endforeach; ?>
            </select>
        </div>
        <div class="form-group">
            <label for="nome">Nome do Pet</label>
            <input type="text" id="nome" name="nome" required placeholder="Ex.: Thor, Mia, Pipoca">
        </div>
        <div class="form-group">
            <label for="especie">Espécie</label>
            <select id="especie" name="especie" required>
                <option value="Canina">Canina</option>
                <option value="Felina">Felina</option>
                <option value="Aves">Aves</option>
                <option value="Roedores">Roedores</option>
            </select>
        </div>
        <div class="form-group">
            <label for="raca">Raça</label>
            <input type="text" id="raca" name="raca" required placeholder="Ex.: Labrador, Siamês, SRD">
        </div>
        <div class="form-group">
            <label for="data_nascimento">Data de Nascimento</label>
            <input type="date" id="data_nascimento" name="data_nascimento" required>
        </div>
        <div style="display:flex; justify-content:space-between; margin-top:20px;">
            <a href="/pets" style="color:#94a3b8; text-decoration:none;">← Voltar</a>
            <button type="submit" class="btn btn-success">Cadastrar Pet</button>
        </div>
    </form>
</div>