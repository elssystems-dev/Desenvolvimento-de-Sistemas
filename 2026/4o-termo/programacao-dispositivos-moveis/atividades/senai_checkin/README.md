# SENAI CheckIn — Registro de Ponto e Diário de Campo com Foto e GPS

Aplicativo mobile desenvolvido para técnicos e fiscais do SENAI realizarem registros de presença, visitas técnicas e inspeções em campo com validação georreferenciada (coordenadas GPS) e documentação visual (câmera nativa).

---

## 🎯 Objetivo da Solução

Garantir a confiabilidade, auditabilidade e agilidade no registro de ponto e diário de campo em atividades externas através de:
1. **Captura Georreferenciada:** Obtenção automática de latitude e longitude via GPS nativo com alta precisão e geocodificação reversa de endereço (OpenStreetMap Nominatim).
2. **Registro Fotográfico:** Captura de fotos em tempo real utilizando a câmera nativa do aparelho via `image_picker`.
3. **Persistência Local Offline-First:** Armazenamento seguro de todos os registros (data/hora, foto, latitude, longitude e observações) em banco SQLite embutido via `sqflite`.
4. **Visualização em Mapa Interativo:** Exibição do histórico de registros com miniaturas das fotos e visualização geográfica no mapa via `flutter_osm_plugin`.
5. **Feedback Imediato:** Confirmação visual em tela e resposta sonora/tátil nativa (`SystemSound` e `HapticFeedback`).

---

## 🏗️ Arquitetura do Projeto

O projeto segue o padrão arquitetural em camadas adotado nas boas práticas do SENAI:

```
lib/
├── components/
│   └── senai_app_bar.dart      # AppBar padronizada com a identidade visual SENAI
├── controller/
│   └── logs_controller.dart    # Camada intermediária de regras de negócio e controle
├── model/
│   └── user_logs.dart          # Modelo de dados com serialização toMap/fromMap
├── service/
│   ├── api_helper.dart         # Geocodificação reversa via OSM Nominatim
│   ├── db_helper.dart          # Gerenciamento SQLite com padrão Singleton
│   └── sql/
│       └── create_tables.dart  # Scripts DDL de criação das tabelas
├── view/
│   ├── check_in.dart           # Tela de registro de novo ponto (Câmera + GPS + Notas)
│   └── log_history.dart        # Tela principal com listagem de pontos e mapa interativo
└── main.dart                   # Ponto de entrada com configuração de tema Material 3
```

---

## ⚙️ Recursos Nativos e Sensores Utilizados

| Recurso | Pacote | Finalidade |
| :--- | :--- | :--- |
| **Permissões em Runtime** | `permission_handler` | Solicitação e validação de permissões de Câmera e Localização. |
| **Localização GPS** | `geolocator` | Aquisição de coordenadas geográficas exatas com precisão. |
| **Câmera do Dispositivo** | `image_picker` | Captura de imagens de evidência em tempo real. |
| **Banco Local Relacional** | `sqflite` / `path` | Persistência offline dos registros e caminhos de arquivo. |
| **Mapa Interativo** | `flutter_osm_plugin` | Visualização do ponto geográfico em mapa OpenStreetMap. |
| **Feedback Sonoro/Tátil** | `flutter/services.dart` | Confirmação auditiva e vibração ao salvar o registro. |

---

## 🚀 Como Executar o Projeto

### Pré-requisitos
- Flutter SDK instalado (versão 3.x)
- Emulador Android configurado ou dispositivo físico conectado via USB com depuração ativada.

### Passos de Execução
```bash
# 1. Obter dependências
flutter pub get

# 2. Executar os testes unitários
flutter test

# 3. Executar o aplicativo no dispositivo/emulador
flutter run
```

---

## 🧪 Testes Automatizados

O projeto conta com suíte de testes unitários para validação de modelagem, conversão de datas e integridade do script SQL:
```bash
flutter test test/user_logs_test.dart
```