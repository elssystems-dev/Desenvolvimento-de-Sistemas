# 🌟 Star Phrases (QuoteGenius)

> **Situação de Aprendizagem 5: O Gerador de Citações ("QuoteGenius" / FavQuote)**  
> Disciplina: Programação para Dispositivos Móveis (4º Termo / 2026)  
> Tecnologias: Flutter & Firebase (Cloud Firestore)

---

## 📖 Sobre o Projeto

O **Star Phrases** é um aplicativo mobile desenvolvido em Flutter integrado ao **Firebase Cloud Firestore**. O objetivo principal é disponibilizar diariamente uma citação inspiradora ("Frase do Dia") de pensadores, filósofos e líderes históricos para os usuários, com atualização em tempo real.

O projeto foi concebido a partir do briefing da **Situação de Aprendizagem 5 (ZenMind / QuoteGenius)**, focando em:
1. **Consumo de API Externa de Citações** (FavQs / ZenQuotes / Quotable).
2. **Integração com Cloud Firestore** no documento `/dailyContent/quoteOfTheDay`.
3. **Escuta Reativa em Tempo Real** utilizando `StreamBuilder` no Flutter.
4. **Simulação Local da Cloud Function Agendada** (conforme instrução docente, devido à paywall do plano Blaze do Firebase).
5. **Configurações de Tema** com chaveamento entre Modo Claro e Modo Escuro (*Dark/Light Switch*).
6. **Tela Sobre Nós (*About Us*)** com placeholders estruturados para customização.

---

## ⚡ Contexto da Simulação Local (Cloud Functions & Paywall)

No escopo original da Situação de Aprendizagem 5, previa-se uma Cloud Function agendada no Firebase para buscar uma citação em uma API externa à meia-noite e gravar no Firestore. No entanto, o serviço de **Cloud Functions do Firebase exige a ativação do plano Blaze (pago / cartão de crédito)** para tráfego externo e agendamento.

Conforme orientação do professor:
- A lógica de backend da Cloud Function foi modelada e implementada como uma **simulação local** (`QuoteSimulationService`).
- O serviço realiza a requisição HTTP para a API da **FavQs** (com fallback automático robusto), grava os campos estruturados (`phrase`, `author`, `imageUrl`, `source`, `updatedAt`) no documento `/dailyContent/quoteOfTheDay` do Firestore.
- No app, o botão de **Sincronização** no AppBar da tela principal permite disparar a simulação a qualquer momento, demonstrando de forma imediata o `StreamBuilder` atualizando os dados na interface em tempo real.
- O arquivo [`simulation/cloud_function_reference.js`](file:///simulation/cloud_function_reference.js) documenta como a função estaria declarada caso estivesse em ambiente de produção com Firebase Scheduler.

---

## 📱 Telas da Aplicação

1. **Frase do Dia (`Phrases`)**:
   - Conectada diretamente ao Firestore via `StreamBuilder`.
   - Exibe a citação em destaque, autor, fonte e imagem correspondente.
   - Ícone de simulação para testar a atualização do documento Firestore ao vivo.
   - Navegação direta para telas de informações e ajustes.
2. **Configurações (`AppSettings`)**:
   - Atende estritamente à especificação: switch dedicado para alternar entre **Modo Claro** e **Modo Escuro** (*Dark/Light Mode*).
   - Gerenciamento reativo de tema com `AppTheme` e `ValueNotifier`.
3. **Sobre Nós (`AboutUs`)**:
   - Apresentação visual da identidade da aplicação.
   - Placeholders organizados em cards estilizados ("Quem Somos", "Nossa Missão", "Equipe & Desenvolvedores") prontos para preenchimento.

---

## 🛠️ Como Executar a Aplicação

### Pré-requisitos
- Flutter SDK (versão 3.12 ou superior)
- Dart SDK
- Emulador Android ou dispositivo físico configurado (com Depuração USB)

### Passos de Instalação

1. Clone o repositório ou abra a pasta do projeto:
   ```bash
   cd star_phrases
   ```

2. Obtenha as dependências:
   ```bash
   flutter pub get
   ```

3. Execute a análise estática para validação de integridade:
   ```bash
   flutter analyze
   ```

4. Inicie o aplicativo:
   ```bash
   flutter run
   ```

---

## 📂 Estrutura de Arquivos

```
star_phrases/
├── lib/
│   ├── firebase_options.dart          # Configuração gerada do Firebase Android
│   ├── main.dart                      # Inicialização do Firebase e ThemeProvider
│   ├── screens/
│   │   ├── phrases.dart               # Tela principal com StreamBuilder do Firestore
│   │   ├── app_settings.dart          # Configurações (Switch Dark/Light Mode)
│   │   └── about_us.dart              # Tela Sobre Nós com placeholders
│   ├── services/
│   │   └── quote_simulation_service.dart # Simulação da Cloud Function e consumo da API
│   └── theme/
│       └── app_theme.dart             # Definição dos temas Claro/Escuro (#f8d830)
├── simulation/
│   └── cloud_function_reference.js    # Código de referência da Cloud Function para Cloud Scheduler
├── assets/
│   └── star_phrases.png               # Ícone e splash screen da aplicação
├── pubspec.yaml                       # Dependências (cloud_firestore, firebase_core, http)
└── README.md                          # Documentação do projeto
```
