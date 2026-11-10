<?php
declare(strict_types=1);

namespace App\Controller;

use App\Controller\Controller;
use App\Model\Tutor;
use App\Model\Pet;
use App\Model\Agendamento;

/**
 * Controller da tela principal do sistema com menu de recursos e metricas.
 */
final class HomeController extends Controller {
    public function index(): void {
        $usuarioNome = $_SESSION['usuario_nome'] ?? 'Operador';
        $totalTutores = count(Tutor::listar());
        $totalPets = Pet::totalPets();
        $agendamentosRecentes = array_slice(Agendamento::listarOrdenadoPorAno(), 0, 5);

        $this->renderizar('home/index', [
            'titulo'               => 'Painel Principal - Clínica Veterinária',
            'usuarioNome'          => $usuarioNome,
            'totalTutores'         => $totalTutores,
            'totalPets'            => $totalPets,
            'agendamentosRecentes' => $agendamentosRecentes
        ]);
    }
}