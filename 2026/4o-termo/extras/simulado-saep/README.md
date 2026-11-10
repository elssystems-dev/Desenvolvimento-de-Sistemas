# Resolução do SAEP: Sistema de Gestão para Clínica Veterinária

**Avaliação Prática de Desempenho dos Estudantes - SAEP**

**Tecnologias**: PHP 8.5, PostgreSQL, PDO (Prepared Statements)

**Arquitetura**: MVC Artesanal, Autoload PSR-4 via Composer

## Apresentação do Projeto e Visão Geral

**Sistema de Gestão Clínica Veterinária - SGCV**

- Segurança LGPD
- Sessão com tempo de expiração (15 min)
- Código Limpo e Princípio SOLID
- Uso de Credenciais
- Preenção Anti Vulnerabilidade (XSS, SQL Injection, CSRG)

## Entregas

### Identificação do Projeto

- **Nome do Sistema**: SisVet - Sistema de Gestão Clínica Veterinária
- **Público-Alvo**: Veterináros, recepcionista e gestores da clínica
- **Problema**: Eliminação dos controles manuais, duplicidade de registro, perda de agendamentos, risco de vazamento de dados (LGPD)

### Requisitos Funcionais (RF)

- **RF-01**: Autenticação do usuário com sessão e expiração => O sistema deve autenticar o usuário com email e senha (hash de criptografia). Exibir alerta em caso de erro. Sessão deve expirar automaticamente após 15 minutos de inatividade
- **RF-02**: Logout => Encerramento da sessão, destruindo os dados do usuário (cookies)
- **RF-03**: Painel principal (Dashboard) => Tela inicial após o login, deve exibir o nome do usuário logado
- **RF-04**: Cadastro detutores (LGPD): Cadastrar informações dos tutores criptografando dados sensíveis (CPF)
- **RF-05** Busca e listagem de tutores => Campo de pesquisa por termo e listagem dos resultados
- **RF-06**: Edição dos tutores => Permitir a alteração dos dados dos tutores
- **RF-07**: Cadastro dos pets com vínculo em tuor => Cadastro de novo pet associado a um tutor
- **RF-08**: Listagem dos pets: Exibir a lista de pets cadastrados
- **RF-09**: Agendamento e listagem de agendamento => O sistema deve permitir cadasrar um agendamento e listar ordenada por data de todos os agendamentos
- **RF-10**: Atualização de agendamento => Permitir alterar informações do agendamento

### Requisitos Não Funcionais (RNF)

- RNF-01: Arquitetura MVC
- RNF-02: Mapeamento via PSR-04
- RNF-03: Proteção e criptografia
- RNF-04: Armazenamento em Banco de Dados Relacional

### Diagrama de Entidades Relacionais (DER)

```mermaid
erDiagram
    title "DER - SisVet"

    usuarios {
        int id PK
        varchar nome
        varchar email UNIQUE
        varchar senha_hash
        varchar perfil
        timestamp criado_em
    }

    tutores {
        int id PK
        varchar nome
        varchar cpf_criptografado
        varchar telefone
        varchar email
        timestamp criado_em
    }

    pets {
        int id PK
        int tutor_id FK
        varchar nome
        varchar especie
        varchar raca
        date data_nascimento
        timestamp cadastrado_em
    }

    agendamentos {
        int id PK
        int tutor_id FK
        int pet_id FK
        int usuario_id FK
        date data_agendamento
        time hora_agendamento
        varchar servico
        varchar status
        text observacao
        timestamp realizado_em
    }

    usuarios ||--o{ agendamentos : "agenda/gerencia"
    tutores ||--o{ pets : "possui (1:N)"
    tutores ||--o{ agendamentos : "responsavel (1:N)"
    pets ||--o{ agendamentos : "paciente (1:N)"
```

## Banco de Dados - Script de Criação e População

Criação do arquivo `schema.sql`

## Construção da Aplicação `sistema/`

### `composer.json`

Configurações do autoload - PSR4