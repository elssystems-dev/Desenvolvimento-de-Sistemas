<div class="card" style="max-width: 600px; margin: 0 auto;">
    <h2><?= htmlspecialchars($titulo) ?></h2>

    <form action="/agendamentos/salvar" method="POST">
        <input type="hidden" name="csrf_token" value="<?= htmlspecialchars($csrfToken ?? '') ?>">
        <div class="form-group">
            <label for="tutor_id">Tutor Responsável</label>
            <select id="tutor_id" name="tutor_id" required>
                <option value="">-- Selecione o Tutor --</option>
                <?php foreach ($tutores as $t): ?>
                    <option value="<?= (int)$t['id'] ?>"><?= htmlspecialchars($t['nome']) ?></option>
                <?php endforeach; ?>
            </select>
        </div>
        <div class="form-group">
            <label for="pet_id">Pet / Paciente</label>
            <select id="pet_id" name="pet_id" required>
                <option value="">-- Selecione o Pet --</option>
                <?php foreach ($pets as $p): ?>
                    <option value="<?= (int)$p['id'] ?>"><?= htmlspecialchars($p['nome']) ?> (Tutor: <?= htmlspecialchars($p['tutor_nome']) ?>)</option>
                <?php endforeach; ?>
            </select>
        </div>
        <div class="form-group">
            <label for="data_agendamento">Data da Consulta</label>
            <input type="date" id="data_agendamento" name="data_agendamento" required>
        </div>
        <div class="form-group">
            <label for="hora_agendamento">Horário</label>
            <input type="time" id="hora_agendamento" name="hora_agendamento" required>
        </div>
        <div class="form-group">
            <label for="servico">Serviço Solicitado</label>
            <input type="text" id="servico" name="servico" required placeholder="Ex.: Consulta de Rotina, Vacinação, Castração">
        </div>
        <div style="display:flex; justify-content:space-between; margin-top:20px;">
            <a href="/agendamentos" style="color:#94a3b8; text-decoration:none;">← Voltar</a>
            <button type="submit" class="btn btn-success">Salvar Agendamento</button>
        </div>
    </form>
</div>