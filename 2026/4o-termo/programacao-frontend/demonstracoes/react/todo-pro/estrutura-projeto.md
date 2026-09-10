# Exploração orientada

1. Qual arquivo contém os scripts do npm?

R: Este arquivo é o `package.json`. Na seção `"scripts"`, cada chave filha serve como um atalho de escrita para comandos do vite.

2. Por que node_modules não deve ser enviado ao Github?

R: O `node_modules` não deve ser enviado para o repositório remoto pois ali consta os arquivos compilados das bibliotecas. O arquivo no qual gerencia as dependências do projeto estão no `package.json` e `package-lock.json`, sendo possível reinstalar os módulos através do npm.

3. Onde ficará o código principal?

R: O código ficará principalmente no `App.jsx`, de acordo com a relação inicial, onde este fornece diretamente a UI para o navegador

4. Qual é o papel do main.jsx?

R: O `main.jsx` tem uma função muito específica que é fornecer/configurar dependências globais para a aplicação, que será entregue somente a partir do App

5. Qual comando cria uma versão de produção?

R: `vite build` ou simplesmente `build` (de acordo com `package.json`) é responsável por compilar o projeto entregar uma versão pronta para ser utilizada.
