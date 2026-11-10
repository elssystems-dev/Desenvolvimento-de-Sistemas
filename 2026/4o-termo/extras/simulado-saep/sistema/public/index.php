<?php
declare(strict_types=1);

// Ponto unico de entrada Front Controller
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}
require_once dirname(__DIR__) . '/vendor/autoload.php';

use App\Core\Roteador;
use App\Core\AuthGuard;
use App\Controller\AuthController;
use App\Controller\HomeController;
use App\Controller\TutorController;
use App\Controller\PetController;
use App\Controller\AgendamentoController;

$roteador = new Roteador();
$guardAutenticado = [[AuthGuard::class, 'proteger']];

// 1. Rotas Publicas de Autenticacao
$roteador->registrar('GET', '/login', [AuthController::class, 'formulario']);
$roteador->registrar('POST', '/login', [AuthController::class, 'login']);
$roteador->registrar('POST', '/logout', [AuthController::class, 'logout'], $guardAutenticado);

// 2. Funcionalidade Principal (Dashboard / Home)
$roteador->registrar('GET', '/', [HomeController::class, 'index'], $guardAutenticado);

// 3. Funcionalidade de Tutores (Busca, Cadastro, Edicao e Listagem)
$roteador->registrar('GET', '/tutores', [TutorController::class, 'listar'], $guardAutenticado);
$roteador->registrar('GET', '/tutores/novo', [TutorController::class, 'formulario'], $guardAutenticado);
$roteador->registrar('POST', '/tutores/salvar', [TutorController::class, 'salvar'], $guardAutenticado);
$roteador->registrar('GET', '/tutores/editar', [TutorController::class, 'formularioEdicao'], $guardAutenticado);
$roteador->registrar('POST', '/tutores/atualizar', [TutorController::class, 'atualizar'], $guardAutenticado);

// 4. Funcionalidade de Pets (Listagem e Cadastro Vinculado ao Tutor)
$roteador->registrar('GET', '/pets', [PetController::class, 'listar'], $guardAutenticado);
$roteador->registrar('GET', '/pets/novo', [PetController::class, 'formulario'], $guardAutenticado);
$roteador->registrar('POST', '/pets/salvar', [PetController::class, 'salvar'], $guardAutenticado);

// 5. Funcionalidade de Agendamentos (Ordenacao por Ano e Atualizacao de Data)
$roteador->registrar('GET', '/agendamentos', [AgendamentoController::class, 'listar'], $guardAutenticado);
$roteador->registrar('GET', '/agendamentos/novo', [AgendamentoController::class, 'formulario'], $guardAutenticado);
$roteador->registrar('POST', '/agendamentos/salvar', [AgendamentoController::class, 'salvar'], $guardAutenticado);
$roteador->registrar('GET', '/agendamentos/editar-data', [AgendamentoController::class, 'formularioEditarData'], $guardAutenticado);
$roteador->registrar('POST', '/agendamentos/atualizar-data', [AgendamentoController::class, 'atualizarData'], $guardAutenticado);

// Despacha a requisicao atual
$roteador->despachar($_SERVER['REQUEST_METHOD'], $_SERVER['REQUEST_URI']);