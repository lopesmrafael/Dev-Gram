# DevGram 📸

Uma galeria de fotos moderna desenvolvida em Flutter com Firebase, inspirada no Instagram. O app permite aos usuários compartilhar, visualizar e gerenciar suas fotos de forma intuitiva e elegante.

## 🚀 Funcionalidades

### 📱 Core Features
- **Autenticação de usuários** com Firebase Auth
- **Upload de fotos** da galeria do dispositivo
- **Galeria em grid 3x3** estilo Instagram
- **Visualização em tela cheia** das fotos
- **Interface responsiva** para web e mobile

### 🔧 Funcionalidades Avançadas
- **Deletar fotos** - Ícone de lixeira para remover suas próprias fotos
- **Compartilhar fotos** - Pressione e segure para compartilhar com outros usuários
- **Segurança por usuário** - Cada usuário vê apenas suas próprias fotos
- **Tratamento de erros** - Ícones de imagem quebrada para falhas de carregamento

### 🎨 Design
- **Tema escuro** com paleta de cinzas harmoniosa
- **Interface minimalista** focada nas fotos
- **Animações suaves** e transições fluidas
- **Tipografia moderna** com pesos variados

## 🛠️ Tecnologias Utilizadas

- **Flutter** - Framework de desenvolvimento
- **Firebase Auth** - Autenticação de usuários
- **Cloud Firestore** - Banco de dados NoSQL
- **Image Picker** - Seleção de imagens
- **Material Design** - Componentes de UI

## 📋 Pré-requisitos

- Flutter SDK (versão 3.0+)
- Dart SDK
- Conta no Firebase
- Android Studio / VS Code
- Dispositivo Android/iOS ou navegador web

## ⚙️ Configuração do Projeto

### 1. Clone o repositório
```bash
git clone https://github.com/seu-usuario/Dev-Gram.git
cd dev_gram
```

### 2. Instale as dependências
```bash
flutter pub get
```

### 3. Configuração do Firebase

#### 3.1 Crie um projeto no Firebase Console
1. Acesse [Firebase Console](https://console.firebase.google.com)
2. Clique em "Criar projeto"
3. Siga as instruções de configuração

#### 3.2 Configure o Firebase Auth
1. No console, vá em "Authentication"
2. Clique em "Começar"
3. Ative o provedor "Email/senha"

#### 3.3 Configure o Cloud Firestore
1. No console, vá em "Firestore Database"
2. Clique em "Criar banco de dados"
3. Escolha "Iniciar no modo de teste"
4. Selecione uma localização

#### 3.4 Adicione o app ao Firebase
1. Clique no ícone do Flutter no console
2. Siga as instruções para Android/iOS/Web
3. Baixe o arquivo de configuração (`google-services.json` para Android, `GoogleService-Info.plist` para iOS)

### 4. Configure as regras de segurança

#### Firestore Rules (`firestore.rules`)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /fotos/{photoId} {
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.userId || 
         request.auth.token.email in resource.data.sharedWith);
      allow write: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
    }
  }
}
```

### 5. Execute o projeto
```bash
flutter run
```

## 📱 Como Usar

### Primeiro Acesso
1. **Cadastro/Login** - Crie uma conta ou faça login
2. **Tela inicial** - Visualize a galeria vazia

### Adicionando Fotos
1. **Toque no botão +** (FloatingActionButton)
2. **Selecione "Selecionar Foto"**
3. **Escolha uma imagem** da galeria
4. **Toque em "Publicar"**

### Gerenciando Fotos
- **Visualizar**: Toque na foto para ver em tela cheia
- **Deletar**: Toque no ícone 🗑️ (apenas suas fotos)
- **Compartilhar**: Pressione e segure → digite email → "Compartilhar"

## 🏗️ Estrutura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada do app
├── auth_screen.dart         # Tela de login/cadastro
├── task_list_screen.dart    # Tela principal da galeria
├── firebase_options.dart    # Configurações do Firebase
└── firestore.rules         # Regras de segurança
```

## 📊 Modelo de Dados

### Coleção: `fotos`
```json
{
  "userId": "string",           // ID do usuário proprietário
  "imageUrl": "string",         // Caminho/URL da imagem
  "storagePath": "string",      // Caminho no storage
  "timestamp": "timestamp",     // Data de criação
  "sharedWith": ["string"]      // Lista de emails compartilhados
}
```

## 🔒 Segurança

- **Autenticação obrigatória** para todas as operações
- **Isolamento por usuário** - cada usuário vê apenas suas fotos
- **Compartilhamento controlado** via lista de emails
- **Regras de segurança** no Firestore impedem acesso não autorizado

## 🎯 Funcionalidades Implementadas

### ✅ Fase 1 - Base
- [x] Autenticação com Firebase Auth
- [x] Upload de imagens
- [x] Galeria em grid
- [x] Armazenamento no Firestore

### ✅ Fase 2 - Melhorias
- [x] Interface moderna
- [x] Tratamento de erros
- [x] Responsividade web/mobile
- [x] Modelo de dados estruturado

### ✅ Fase 3 - Avançado
- [x] Deletar fotos
- [x] Compartilhar fotos
- [x] Regras de segurança avançadas
- [x] Interface de compartilhamento

## 🚧 Limitações Conhecidas

- **Persistência de imagens**: URLs blob não persistem após recarregar a página web
- **Tamanho de imagens**: Não há compressão automática
- **Offline**: Não funciona sem conexão com internet

## 🔮 Melhorias Futuras

- [ ] Implementar Firebase Storage para persistência real
- [ ] Adicionar compressão de imagens
- [ ] Sistema de likes e comentários
- [ ] Feed de fotos compartilhadas
- [ ] Notificações push
- [ ] Modo offline com sincronização

## 🤝 Contribuindo

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 👨‍💻 Autor

**Rafael Lopes** - [GitHub](https://github.com/lopesmrafael)
**Luiz Otavio** - [GitHub](https://github.com/LuisOGCosta)









