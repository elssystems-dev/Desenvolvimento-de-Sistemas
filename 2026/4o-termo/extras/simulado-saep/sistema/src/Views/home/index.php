<div class="card">
    <h2><?= htmlspecialchars($titulo) ?></h2>
    <p style="color: #94a3b8;">
        Bem-vindo(a), <strong><?= htmlspecialchars($usuarioNome) ?></strong>. Selecione uma das opções abaixo para gerenciar a clínica:
    </p>

    <div class="grid-stats">
        <div class="stat-box">
            <span>Tutores Cadastrados</span>
            <strong><?= (int)$totalTutores ?></strong>
            <a href="/tutores" class="btn" style="margin-top:12px; font-size:0.75rem;">Gerenciar Tutores</a>
        </div>
        <div class="stat-box">
            <span>Pets Registrados</span>
            <strong><?= (int)$totalPets ?></strong>
            <a href="/pets" class="btn" style="margin-top:12px; font-size:0.75rem;">Gerenciar Pets</a>
        </div>
        <div class="stat-box">
            <span>Agendamentos</span>
            <strong style="color:#4ade80;">Consultas</strong>
            <a href="/agendamentos" class="btn btn-success" style="margin-top:12px; font-size:0.75rem;">Ver Agendamentos</a>
        </div>
    </div>

    <h3 style="margin-top:35px; border-bottom:1px solid #334155; padding-bottom:8px;">Próximos Atendimentos</h3>
    <table>
        <thead>
            <tr>
                <th>Data</th>
                <th>Horário</th>
                <th>Paciente (Pet)</th>
                <th>Tutor Responsável</th>
                <th>Procedimento</th>
            </tr>
        </thead>
        <tbody>
            <?php if (empty($agendamentosRecentes)): ?>
                <tr><td colspan="5" style="text-align:center; color:#94a3b8;">Nenhum agendamento recente.</td></tr>
            <?php else: ?>
                <?php foreach ($agendamentosRecentes as $a): ?>
                    <tr>
                        <td><?= htmlspecialchars(date('d/m/Y', strtotime($a['data_agendamento']))) ?></td>
                        <td><?= htmlspecialchars(substr($a['hora_agendamento'], 0, 5)) ?></td>
                        <td><strong><?= htmlspecialchars($a['pet_nome']) ?></strong> (<?= htmlspecialchars($a['pet_especie']) ?>)</td>
                        <td><?= htmlspecialchars($a['tutor_nome']) ?></td>
                        <td><?= htmlspecialchars($a['servico']) ?></td>
                    </tr>
                <?php endforeach; ?>
            <?php endif; ?>
        </tbody>
    </table>
</div>