<div class="card" style="max-width: 500px; margin: 0 auto;">
    <h2><?= htmlspecialchars($titulo) ?></h2>
    <p style="color:#94a3b8; font-size:0.88rem;">
        Paciente: <strong><?= htmlspecialchars($agendamento['pet_nome']) ?></strong> | 
        Tutor: <strong><?= htmlspecialchars($agendamento['tutor_nome']) ?></strong>
    </p>

    <form action="/agendamentos/atualizar-data" method="POST">
        <input type="hidden" name="csrf_token" value="<?= htmlspecialchars($csrfToken ?? '') ?>">
        <input type="hidden" name="id" value="<?= (int)$agendamento['id'] ?>">

        <div class="form-group">
            <label for="data_agendamento">Nova Data de Agendamento</label>
            <input type="date" id="data_agendamento" name="data_agendamento" value="<?= htmlspecialchars($agendamento['data_agendamento']) ?>" required>
        </div>

        <div class="form-group">
            <label for="hora_agendamento">Novo Horário</label>
            <input type="time" id="hora_agendamento" name="hora_agendamento" value="<?= htmlspecialchars(substr($agendamento['hora_agendamento'], 0, 5)) ?>">
        </div>

        <div style="display:flex; justify-content:space-between; margin-top:20px;">
            <a href="/agendamentos" style="color:#94a3b8; text-decoration:none;">← Cancelar</a>
            <button type="submit" class="btn btn-success">Salvar Nova Data</button>
        </div>
    </form>
</div>