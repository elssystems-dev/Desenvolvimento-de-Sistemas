<div class="card" style="max-width: 600px; margin: 0 auto;">
    <h2><?= htmlspecialchars($titulo) ?></h2>

    <form action="/tutores/atualizar" method="POST">
        <input type="hidden" name="csrf_token" value="<?= htmlspecialchars($csrfToken ?? '') ?>">
        <input type="hidden" name="id" value="<?= (int)$tutor['id'] ?>">

        <div class="form-group">
            <label for="nome">Nome Completo</label>
            <input type="text" id="nome" name="nome" value="<?= htmlspecialchars($tutor['nome']) ?>" required>
        </div>
        <div class="form-group">
            <label for="cpf">CPF (Criptografia Mantida no Banco)</label>
            <input type="text" id="cpf" name="cpf" value="<?= htmlspecialchars($tutor['cpf']) ?>" required>
        </div>
        <div class="form-group">
            <label for="telefone">Telefone</label>
            <input type="text" id="telefone" name="telefone" value="<?= htmlspecialchars($tutor['telefone']) ?>" required>
        </div>
        <div class="form-group">
            <label for="email">E-mail</label>
            <input type="email" id="email" name="email" value="<?= htmlspecialchars($tutor['email']) ?>" required>
        </div>
        <div style="display:flex; justify-content:space-between; margin-top:20px;">
            <a href="/tutores" style="color:#94a3b8; text-decoration:none;">← Cancelar</a>
            <button type="submit" class="btn">Salvar Alterações</button>
        </div>
    </form>
</div>