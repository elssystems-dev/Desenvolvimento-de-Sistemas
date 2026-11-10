<div class="card">
    <div style="display:flex; justify-content:space-between; align-items:center;">
        <div>
            <h2><?= htmlspecialchars($titulo) ?></h2>
            <p style="color:#94a3b8; font-size:0.85rem; margin-top:4px;">
                Ordenado cronologicamente por ano de agendamento com dados completos do paciente e do tutor.
            </p>
        </div>
        <a href="/agendamentos/novo" class="btn btn-success">+ Novo Agendamento</a>
    </div>

    <table>
        <thead>
            <tr>
                <th>Ano</th>
                <th>Data / Hora</th>
                <th>Paciente (Pet)</th>
                <th>Tutor Responsável</th>
                <th>Contato Tutor</th>
                <th>Serviço</th>
                <th style="text-align:right;">Ações</th>
            </tr>
        </thead>
        <tbody>
            <?php if (empty($agendamentos)): ?>
                <tr><td colspan="7" style="text-align:center; color:#94a3b8;">Nenhum agendamento cadastrado.</td></tr>
            <?php else: ?>
                <?php foreach ($agendamentos as $a): ?>
                    <tr>
                        <td><span style="background:#0369a1; padding:3px 8px; border-radius:4px; font-weight:bold; font-size:0.8rem;"><?= htmlspecialchars((string)$a['ano_agendamento']) ?></span></td>
                        <td><strong><?= htmlspecialchars(date('d/m/Y', strtotime($a['data_agendamento']))) ?></strong> às <?= htmlspecialchars(substr($a['hora_agendamento'], 0, 5)) ?></td>
                        <td><?= htmlspecialchars($a['pet_nome']) ?> <span style="color:#94a3b8;">(<?= htmlspecialchars($a['pet_raca']) ?>)</span></td>
                        <td><?= htmlspecialchars($a['tutor_nome']) ?></td>
                        <td><?= htmlspecialchars($a['tutor_telefone']) ?></td>
                        <td><?= htmlspecialchars($a['servico']) ?></td>
                        <td style="text-align:right;">
                            <a href="/agendamentos/editar-data?id=<?= (int)$a['id'] ?>" class="btn" style="padding:4px 8px; font-size:0.75rem; background:#059669;">
                                Alterar Data
                            </a>
                        </td>
                    </tr>
                <?php endforeach; ?>
            <?php endif; ?>
        </tbody>
    </table>
</div>