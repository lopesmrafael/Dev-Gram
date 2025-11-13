# 📁 Estrutura do Projeto DevGram

## 🗂️ Organização das Pastas

```
lib/
├── 📱 screens/           # Telas do aplicativo
│   ├── auth_screen.dart      # Tela de login/cadastro
│   └── gallery_screen.dart   # Tela principal da galeria
│
├── 🧩 widgets/           # Componentes reutilizáveis
│   ├── photo_grid_item.dart  # Item da galeria com like/delete
│   └── add_photo_dialog.dart # Modal para adicionar fotos
│
├── 🔧 services/          # Lógica de negócio e APIs
│   ├── photo_service.dart    # Operações CRUD de fotos
│   └── image_service.dart    # Gerenciamento de imagens
│
├── 📊 models/            # Modelos de dados
│   └── photo_model.dart      # Modelo da foto
│
├── 🛠️ utils/             # Utilitários e helpers
│   └── dialogs.dart          # Diálogos reutilizáveis
│
├── main.dart             # Ponto de entrada
└── firebase_options.dart # Configurações Firebase
```

## 📱 Screens (Telas)

### `auth_screen.dart`
- **Função**: Tela de autenticação (login/cadastro)
- **Responsabilidades**: 
  - Formulários de login e cadastro
  - Validação de credenciais
  - Integração com Firebase Auth

### `gallery_screen.dart`
- **Função**: Tela principal da galeria de fotos
- **Responsabilidades**:
  - Exibir grid de fotos 3x3
  - Gerenciar estado da galeria
  - Coordenar ações (adicionar, deletar, curtir)

## 🧩 Widgets (Componentes)

### `photo_grid_item.dart`
- **Função**: Item individual da galeria
- **Responsabilidades**:
  - Exibir foto com overlay
  - Botões de curtir e deletar
  - Contador de likes
  - Tratamento de erros de imagem

### `add_photo_dialog.dart`
- **Função**: Modal para adicionar novas fotos
- **Responsabilidades**:
  - Seleção de imagem da galeria
  - Preview da imagem selecionada
  - Upload e salvamento

## 🔧 Services (Serviços)

### `photo_service.dart`
- **Função**: Gerenciamento de fotos no Firestore
- **Responsabilidades**:
  - CRUD de fotos (Create, Read, Update, Delete)
  - Sistema de likes
  - Compartilhamento de fotos
  - Stream de fotos do usuário

### `image_service.dart`
- **Função**: Operações com imagens
- **Responsabilidades**:
  - Seleção de imagens (ImagePicker)
  - Geração de nomes de arquivo
  - Paths de armazenamento
  - Compatibilidade Web/Mobile

## 📊 Models (Modelos)

### `photo_model.dart`
- **Função**: Estrutura de dados da foto
- **Responsabilidades**:
  - Definir campos da foto
  - Conversão Firestore ↔ Dart
  - Tipagem segura dos dados

## 🛠️ Utils (Utilitários)

### `dialogs.dart`
- **Função**: Diálogos e mensagens reutilizáveis
- **Responsabilidades**:
  - Confirmação de exclusão
  - Compartilhamento de fotos
  - Visualização de fotos
  - SnackBars de feedback

## 🎯 Vantagens desta Estrutura

### ✅ **Organização Clara**
- Cada pasta tem uma responsabilidade específica
- Fácil localização de arquivos
- Estrutura escalável

### ✅ **Reutilização de Código**
- Widgets podem ser usados em várias telas
- Services centralizados evitam duplicação
- Utils padronizam comportamentos

### ✅ **Manutenibilidade**
- Mudanças isoladas por responsabilidade
- Testes mais fáceis de implementar
- Debugging simplificado

### ✅ **Colaboração**
- Desenvolvedores sabem onde encontrar cada tipo de código
- Padrão consistente em todo o projeto
- Onboarding mais rápido

## 🔄 Fluxo de Dados

```
User Action → Screen → Service → Firestore
     ↓           ↓        ↓         ↓
   Widget ← Model ← Utils ← Response
```

## 📝 Convenções de Nomenclatura

- **Screens**: `*_screen.dart`
- **Widgets**: `*_widget.dart` ou nome descritivo
- **Services**: `*_service.dart`
- **Models**: `*_model.dart`
- **Utils**: Nome descritivo da funcionalidade

Esta estrutura torna o projeto mais profissional, organizando e facilitando futuras expansões e manutenções!