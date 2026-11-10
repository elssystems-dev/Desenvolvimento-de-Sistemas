<?php
declare(strict_types=1);

namespace App\Controller;

use App\Controller\Controller;
use App\Model\Agendamento;
use App\Model\Tutor;
use App\Model\Pet;

/**
 * Controller para agendamentos ordenados por ano e atualizacao de datas.
 */
final class AgendamentoController extends Controller {
    public function listar(): void {
        $agendamentos = Agendamento::listarOrdenadoPorAno();
        $this->renderizar('agendamentos/listar', [
            'titulo'       => 'Agendamentos da Clínica (Ordenados por Ano)',
            'agendamentos' => $agendamentos
        ]);
    }

    public function formulario(): void {
        $tutores = Tutor::listar();
        $pets = Pet::listarTodos();
        $this->renderizar('agendamentos/criar', [
            'titulo'    => 'Novo Agendamento',
            'tutores'   => $tutores,
            'pets'      => $pets,
            'csrfToken' => $this->obterCsrfToken()
        ]);
    }

    public function salvar(): void {
        if (!$this->validarCsrfToken($_POST['csrf_token'] ?? null)) {
            $this->redirecionar('/agendamentos');
        }
        $tutId  = (int)($_POST['tutor_id'] ?? 0);
        $petId  = (int)($_POST['pet_id'] ?? 0);
        $dt     = trim($_POST['data_agendamento'] ?? '');
        $hr     = trim($_POST['hora_agendamento'] ?? '');
        $serv   = trim($_POST['servico'] ?? '');
        $usrId  = (int)($_SESSION['usuario_id'] ?? 1);

        if ($tutId > 0 && $petId > 0 && $dt !== '' && $hr !== '' && $serv !== '') {
            Agendamento::salvar($tutId, $petId, $usrId, $dt, $hr, $serv);
            $this->redirecionar('/agendamentos');
        }
        $this->redirecionar('/agendamentos/novo');
    }

    public function formularioEditarData(): void {
        $id = (int)($_GET['id'] ?? 0);
        $agendamento = Agendamento::buscarPorId($id);
        if (!$agendamento) {
            $this->redirecionar('/agendamentos');
        }
        $this->renderizar('agendamentos/editar_data', [
            'titulo'      => 'Atualizar Data do Agendamento #' . $id,
            'agendamento' => $agendamento,
            'csrfToken'   => $this->obterCsrfToken()
        ]);
    }

    public function atualizarData(): void {
        if (!$this->validarCsrfToken($_POST['csrf_token'] ?? null)) {
            $this->redirecionar('/agendamentos');
        }
        $id   = (int)($_POST['id'] ?? 0);
        $novaData = trim($_POST['data_agendamento'] ?? '');
        $novaHora = trim($_POST['hora_agendamento'] ?? '');

        if ($id > 0 && $novaData !== '') {
            Agendamento::atualizarData($id, $novaData, $novaHora !== '' ? $novaHora : null);
            $this->redirecionar('/agendamentos');
        }
        $this->redirecionar('/agendamentos/editar-data?id=' . $id);
    }
}