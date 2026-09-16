# E-Commerce com React

Para o desenvolvimento de um comércio virtual/loja de produtos genérico, este diretório trabalha com React.js, uma biblioteca extensível a framework criado pelo Facebook em 2013, sendo liberado para o público

## Guia de instalação

Para criar e executar um projeto com React, é necessário possuir o pacote Node.js instalado no computador para possibilitar os usos de comandos npm (Node Package Manager).

Com o pacote instalado, o principal comando para criar a aplicação através do vite é:

```bash
npm create vite@latest <projeto>
```

Após pressionar Enter, o terminal exibirá uma tela de seleção controlável movida pelas setas do teclado e confirmação com Enter.

O E-Commerce utiliza:

- Framework: React
- Variant: Javascript
- Linter: ESLint

## Conceitos do React

Renderização: É o processo em que o React executa a função do componente, calcula o JSX retornado e atualiza a estrutura do HTML (DOM). Acontece na montagem inicial ou sempre que um state ou prop é alterado.

Efeitos Colaterais (Side Effects): São operações que afetam algo fora do escopo direto de renderização pura da função do componente — como buscar dados em uma API, modificar o localStorage, registrar eventos no navegador ou alterar o título da aba.

Dependências do useEffect: É o array informado no segundo argumento da função ([produtos]). Ele dita a frequência de execução do efeito:

Array Vazio []: Executa o efeito apenas uma vez, quando o componente é montado na tela.

Array com Variáveis [produtos]: Executa na montagem e toda vez que o valor de qualquer elemento da lista mudar.

Sem Array: Executa em absolutamente todas as renderizações do componente.

## CORS

CORS (Cross-Origin Resource Sharing ou Compartilhamento de Recursos com Origens Diferentes) é um mecanismo de segurança integrado aos navegadores.

Por padrão, a política de mesma origem (Same-Origin Policy) impede que uma aplicação web rodando em um domínio/porta (ex: React em http://localhost:5173) faça requisições HTTP para uma API em outro domínio/porta (ex: Express em http://localhost:5000).

Para que o React consiga consumir a API sem ser bloqueado pelo navegador, o servidor Node.js precisa enviar cabeçalhos HTTP especiais (como Access-Control-Allow-Origin: *), liberando o acesso. É exatamente essa liberação que o pacote cors() do Express faz automaticamente.