<?php
declare(strict_types=1);

namespace App\Controller;

use App\Controller\Controller;
use App\Model\Pet;
use App\Model\Tutor;

/**
 * Controller para cadastro e exibicao dos pets vinculados a seus tutores.
 */
final class PetController extends Controller {

    //lista todos os pet
    public function listar(): void {
        $pets = Pet::listarTodos();
        $this->renderizar('pets/listar', [
            'titulo' => 'Gerenciamento de Pets',
            'pets'   => $pets
        ]);
    }

    //renderiza o formulario de cadastro de pet
    public function formulario(): void {
        $tutores = Tutor::listar();
        $this->renderizar('pets/criar', [
            'titulo'    => 'Cadastrar Novo Pet',
            'tutores'   => $tutores,
            'csrfToken' => $this->obterCsrfToken()
        ]);
    }

    // salva um pet novo
    public function salvar(): void {
        if (!$this->validarCsrfToken($_POST['csrf_token'] ?? null)) {
            $this->redirecionar('/pets');
        }
        $tutorId = (int)($_POST['tutor_id'] ?? 0);
        $nome    = trim($_POST['nome'] ?? '');
        $especie = trim($_POST['especie'] ?? '');
        $raca    = trim($_POST['raca'] ?? '');
        $dtNasc  = trim($_POST['data_nascimento'] ?? '');

        if ($tutorId > 0 && $nome !== '' && $especie !== '' && $dtNasc !== '') {
            Pet::salvar($tutorId, $nome, $especie, $raca, $dtNasc);
            $this->redirecionar('/pets');
        }
        $this->renderizar('pets/criar', [
            'titulo'    => 'Cadastrar Novo Pet',
            'erro'      => 'É obrigatório selecionar um tutor e preencher os dados do animal.',
            'tutores'   => Tutor::listar(),
            'csrfToken' => $this->obterCsrfToken()
        ]);
    }
}