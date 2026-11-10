<?php
declare(strict_types=1);

namespace App\Controller;

use App\Controller\Controller;
use App\Model\Usuario;

/**
 * Controller de login, controle de sessao e encerramento de acesso.
 */
final class AuthController extends Controller {
    //renderiza o formulario de login
    public function formulario(): void {
        $expirada = isset($_GET['expirada']) ? 'Sua sessão expirou por inatividade. Faça login novamente.' : null;
        $this->renderizar('auth/login', [
            'titulo'    => 'Login - Clínica Veterinária VetCare',
            'erro'      => $expirada,
            'csrfToken' => $this->obterCsrfToken()
        ]);
    }
    //valido o login
    public function login(): void {
        if (!$this->validarCsrfToken($_POST['csrf_token'] ?? null)) {
            $this->renderizar('auth/login', ['titulo' => 'Login', 'erro' => 'Token CSRF inválido ou expirado.']);
            return;
        }
        $email = trim($_POST['email'] ?? '');
        $senha = (string)($_POST['senha'] ?? '');
        $usuario = Usuario::buscarPorEmail($email);

        if ($usuario && password_verify($senha, $usuario['senha_hash'])) {
            session_regenerate_id(true);
            $_SESSION['usuario_id']     = (int)$usuario['id'];
            $_SESSION['usuario_nome']   = $usuario['nome'];
            $_SESSION['usuario_perfil'] = $usuario['perfil'];
            $_SESSION['ultimo_acesso']  = time();
            $this->redirecionar('/');
        }
        $this->renderizar('auth/login', [
            'titulo'    => 'Login',
            'erro'      => 'Falha na autenticação: E-mail ou senha incorretos.',
            'csrfToken' => $this->obterCsrfToken()
        ]);
    }
    //executa o logout
    public function logout(): void {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }
        $_SESSION = [];
        session_destroy();
        $this->redirecionar('/login');
    }
}