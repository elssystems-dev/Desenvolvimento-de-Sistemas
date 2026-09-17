# Programação Front-End 2

## Angular

O framework Angular é uma plataforma para construção de aplicações web. Ele permite criar aplicações de página única (SPA) com uma arquitetura baseada em componentes, facilitando a manutenção e escalabilidade do código.

### História

O Angular foi desenvolvido pelo Google e lançado em 2010 como AngularJS. Em 2016, o Angular 2 foi lançado, trazendo uma reescrita completa do framework com foco em desempenho e modularidade. Desde então, o Angular tem evoluído continuamente, com versões regulares que introduzem novos recursos e melhorias.

O Angular utiliza TypeScript como linguagem principal, o que proporciona tipagem estática e recursos avançados de desenvolvimento. Ele também oferece um sistema de injeção de dependência, roteamento, formulários reativos e muito mais.

### Estrutura de um Projeto Angular

- `src/`: Diretório principal do código-fonte.
  - `app/`: Contém os componentes, serviços e módulos da aplicação.
  - `assets/`: Armazena arquivos estáticos como imagens e estilos.
  - `environments/`: Configurações de ambiente para desenvolvimento e produção.

### Componentes

Componentes são blocos reutilizáveis de código que encapsulam a lógica, o template e o estilo de uma parte da interface do usuário. Cada componente é definido por um arquivo TypeScript, um arquivo HTML e um arquivo CSS.

#### Exemplo de Componente

```typescript
import { Component } from '@angular/core';

@Component({
  selector: 'app-example',
  templateUrl: './example.component.html',
  styleUrls: ['./example.component.css']
})
export class ExampleComponent {
  // Lógica do componente
}
```

### Serviços

Serviços são classes que fornecem funcionalidades compartilhadas entre diferentes componentes. Eles são usados para gerenciar dados, fazer chamadas HTTP e encapsular lógica de negócios.

#### Exemplo de Serviço

```typescript
import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class ExampleService {
  // Lógica do serviço
}
```

### Módulos

Módulos são contêineres que agrupam componentes, serviços e outros módulos relacionados. O módulo principal da aplicação é o `AppModule`, que é definido no arquivo `app.module.ts`.

#### Exemplo de Módulo

```typescript
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { AppComponent } from './app.component';

@NgModule({
  declarations: [
    AppComponent,
    // Outros componentes
  ],
  imports: [
    BrowserModule,
    // Outros módulos
  ],
  providers: [],
  bootstrap: [AppComponent]
})

export class AppModule { }
```

## React

O React é uma biblioteca JavaScript para construção de interfaces de usuário. Ele permite criar componentes reutilizáveis e gerenciar o estado da aplicação de forma eficiente.

### História

O React foi desenvolvido pelo Facebook e lançado em 2013. Ele introduziu o conceito de Virtual DOM, que melhora o desempenho da atualização da interface do usuário. O React é amplamente utilizado para construir aplicações web modernas e é conhecido por sua simplicidade e flexibilidade.

### Estrutura de um Projeto React

- `src/`: Diretório principal do código-fonte.
  - `components/`: Contém os componentes da aplicação.
  - `services/`: Armazena serviços e lógica de negócios.
  - `App.js`: Componente principal da aplicação.

### Componentes

Componentes no React são funções ou classes que retornam elementos JSX, que descrevem a interface do usuário. Eles podem receber propriedades (props) e gerenciar seu próprio estado.

#### Exemplo de Componente Funcional

```javascript
import React from 'react';

function ExampleComponent(props) {
  return (
    <div>
      <h1>{props.title}</h1>
      <p>{props.description}</p>
    </div>
  );
}
```



