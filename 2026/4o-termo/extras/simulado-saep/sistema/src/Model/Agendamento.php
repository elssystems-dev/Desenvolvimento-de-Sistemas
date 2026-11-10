<?php
declare(strict_types=1);

namespace App\Model;

use App\Core\ConexaoBanco;
use PDO;

/**
 * Modelo de negocio para consultas e atualizacao de datas de agendamentos.
 */
final class Agendamento {
    private static function pdo(): PDO {
        $cfg = dirname(__DIR__, 2) . '/config/database.ini';
        return ConexaoBanco::obterConexao($cfg);
    }

    public static function listarOrdenadoPorAno(): array {
        $sql = "SELECT a.id, a.data_agendamento, a.hora_agendamento, a.servico, a.status, a.observacoes,
                       EXTRACT(YEAR FROM a.data_agendamento) AS ano_agendamento,
                       t.id AS tutor_id, t.nome AS tutor_nome, t.telefone AS tutor_telefone, t.email AS tutor_email,
                       p.id AS pet_id, p.nome AS pet_nome, p.especie AS pet_especie, p.raca AS pet_raca,
                       u.nome AS responsavel_nome
                FROM agendamentos a
                JOIN tutores t ON t.id = a.tutor_id
                JOIN pets p ON p.id = a.pet_id
                JOIN usuarios u ON u.id = a.usuario_id
                ORDER BY EXTRACT(YEAR FROM a.data_agendamento) ASC, a.data_agendamento ASC, a.hora_agendamento ASC";
        return self::pdo()->query($sql)->fetchAll();
    }

    public static function buscarPorId(int $id): ?array {
        $sql = "SELECT a.id, a.data_agendamento, a.hora_agendamento, a.servico, a.status,
                       t.nome AS tutor_nome, p.nome AS pet_nome
                FROM agendamentos a
                JOIN tutores t ON t.id = a.tutor_id
                JOIN pets p ON p.id = a.pet_id
                WHERE a.id = :id LIMIT 1";
        $stmt = self::pdo()->prepare($sql);
        $stmt->execute([':id' => $id]);
        $res = $stmt->fetch();
        return $res ?: null;
    }

    public static function salvar(int $tutId, int $petId, int $usrId, string $dt, string $hr, string $serv): bool {
        $sql = "INSERT INTO agendamentos (tutor_id, pet_id, usuario_id, data_agendamento, hora_agendamento, servico) 
                VALUES (:tut, :pet, :usr, :dt, :hr, :serv)";
        $stmt = self::pdo()->prepare($sql);
        return $stmt->execute([
            ':tut'  => $tutId, ':pet' => $petId, ':usr' => $usrId,
            ':dt'   => $dt, ':hr' => $hr, ':serv' => trim($serv)
        ]);
    }

    public static function atualizarData(int $id, string $novaData, ?string $novaHora = null): bool {
        if ($novaHora !== null && trim($novaHora) !== '') {
            $sql = "UPDATE agendamentos SET data_agendamento = :dt, hora_agendamento = :hr WHERE id = :id";
            $params = [':dt' => $novaData, ':hr' => $novaHora, ':id' => $id];
        } else {
            $sql = "UPDATE agendamentos SET data_agendamento = :dt WHERE id = :id";
            $params = [':dt' => $novaData, ':id' => $id];
        }
        $stmt = self::pdo()->prepare($sql);
        return $stmt->execute($params);
    }
}