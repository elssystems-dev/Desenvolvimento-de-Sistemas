<div class="card" style="max-width: 600px; margin: 0 auto;">
    <h2><?= htmlspecialchars($titulo) ?></h2>
    <?php if (!empty($erro)): ?>
        <div class="alerta-erro"><?= htmlspecialchars($erro) ?></div>
    <?php endif; ?>

    <form action="/tutores/salvar" method="POST">
        <input type="hidden" name="csrf_token" value="<?= htmlspecialchars($csrfToken ?? '') ?>">
        <div class="form-group">
            <label for="nome">Nome Completo</label>
            <input type="text" id="nome" name="nome" required placeholder="Ex.: Mariana Fernandes">
        </div>
        <div class="form-group">
            <label for="cpf">CPF (Será Criptografado com AES-256)</label>
            <input type="text" id="cpf" name="cpf" required placeholder="000.000.000-00">
        </div>
        <div class="form-group">
            <label for="telefone">Telefone para Contato</label>
            <input type="text" id="telefone" name="telefone" required placeholder="(11) 99999-9999">
        </div>
        <div class="form-group">
            <label for="email">E-mail</label>
            <input type="email" id="email" name="email" required placeholder="tutor@email.com">
        </div>
        <div style="display:flex; justify-content:space-between; margin-top:20px;">
            <a href="/tutores" style="color:#94a3b8; text-decoration:none;">← Voltar</a>
            <button type="submit" class="btn btn-success">Salvar Tutor</button>
        </div>
    </form>
</div>