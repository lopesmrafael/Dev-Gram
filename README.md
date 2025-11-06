# DevGram 📸

Uma galeria de fotos moderna desenvolvida em Flutter com Firebase, inspirada no Instagram. O app permite aos usuários compartilhar, visualizar e gerenciar suas fotos de forma intuitiva e elegante.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

## 🚀 Funcionalidades

### 📱 Core Features
- ✅ **Autenticação de usuários** com Firebase Auth (email/senha)
- ✅ **Upload de fotos** da galeria do dispositivo
- ✅ **Galeria em grid 3x3** estilo Instagram
- ✅ **Visualização em tela cheia** das fotos
- ✅ **Interface responsiva** para web e mobile

### 🔧 Funcionalidades Avançadas
- ✅ **Deletar fotos** - Ícone de lixeira para remover suas próprias fotos
- ✅ **Compartilhar fotos** - Pressione e segure para compartilhar com outros usuários
- ✅ **Segurança por usuário** - Cada usuário vê apenas suas próprias fotos
- ✅ **Tratamento de erros** - Ícones de imagem quebrada para falhas de carregamento
- ✅ **Regras de segurança** - Firestore com controle de acesso avançado

### 🎨 Design
- 🎯 **Tema escuro** com paleta de cinzas harmoniosa
- 🎯 **Interface minimalista** focada nas fotos
- 🎯 **Animações suaves** e transições fluidas
- 🎯 **Tipografia moderna** com pesos variados
- 🎯 **Material Design 3** com componentes atualizados

## 🛠️ Tecnologias Utilizadas

| Tecnologia | Versão | Uso |
|------------|--------|-----|
| **Flutter** | 3.0+ | Framework de desenvolvimento |
| **Firebase Auth** | Latest | Autenticação de usuários |
| **Cloud Firestore** | Latest | Banco de dados NoSQL |
| **Image Picker** | ^1.0.0 | Seleção de imagens |
| **Material Design** | 3.0 | Componentes de UI |

## 📋 Pré-requisitos

- Flutter SDK (versão 3.0+)
- Dart SDK (versão 3.0+)
- Conta no Firebase
- Android Studio / VS Code
- Dispositivo Android/iOS ou navegador web

## ⚙️ Configuração do Projeto

### 1. Clone o repositório
```bash
git clone https://github.com/lopesmrafael/Dev-Gram.git
cd Dev-Gram
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
4. Selecione uma localização (recomendado: southamerica-east1)

#### 3.4 Adicione o app ao Firebase
1. Clique no ícone do Flutter no console
2. Siga as instruções para Android/iOS/Web
3. Baixe os arquivos de configuração:
   - `google-services.json` (Android)
   - `GoogleService-Info.plist` (iOS)
   - `firebase_options.dart` (Web/All)

### 4. Configure as regras de segurança

#### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Regras para a coleção 'fotos'
    match /fotos/{photoId} {
      // Permite leitura se o usuário é o dono OU está na lista sharedWith
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.userId || 
         request.auth.token.email in resource.data.sharedWith);
      
      // Permite escrita apenas para o dono da foto
      allow write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
      
      // Permite criação apenas com o próprio userId
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.userId;
    }
  }
}
```

### 5. Execute o projeto
```bash
# Para desenvolvimento
flutter run

# Para web
flutter run -d chrome

# Para build de produção
flutter build apk
flutter build web
```

## 📱 Como Usar

### Primeiro Acesso
1. **Cadastro/Login** - Crie uma conta ou faça login com email/senha
2. **Tela inicial** - Visualize a galeria vazia com mensagem de boas-vindas

### Adicionando Fotos
1. **Toque no botão +** (FloatingActionButton cinza)
2. **Selecione "Selecionar Foto"** no modal
3. **Escolha uma imagem** da galeria do dispositivo
4. **Visualize o preview** da imagem selecionada
5. **Toque em "Publicar"** para salvar

### Gerenciando Fotos
- **👆 Visualizar**: Toque na foto para ver em tela cheia
- **🗑️ Deletar**: Toque no ícone vermelho (apenas suas fotos)
- **📤 Compartilhar**: Pressione e segure → digite email → "Compartilhar"
- **🚪 Sair**: Toque no ícone de logout no AppBar

## 🏗️ Estrutura do Projeto

```
dev_gram/
├── lib/
│   ├── main.dart                 # Ponto de entrada do app
│   ├── auth_screen.dart         # Tela de login/cadastro
│   ├── task_list_screen.dart    # Tela principal da galeria
│   └── firebase_options.dart    # Configurações do Firebase
├── firestore.rules              # Regras de segurança do Firestore
├── storage.rules               # Regras de segurança do Storage
├── pubspec.yaml                # Dependências do projeto
└── README.md                   # Documentação
```

## 📊 Modelo de Dados

### Coleção: `fotos`
```json
{
  "userId": "string",           // ID do usuário proprietário
  "imageUrl": "string",         // Caminho/URL da imagem local
  "storagePath": "string",      // Caminho no storage (futuro)
  "timestamp": "timestamp",     // Data de criação
  "sharedWith": ["string"]      // Lista de emails compartilhados
}
```

### Exemplo de documento:
```json
{
  "userId": "abc123def456",
  "imageUrl": "blob:http://localhost:59561/uuid-here",
  "storagePath": "fotos/imagem_1703123456789.jpg",
  "timestamp": "2024-01-15T10:30:00Z",
  "sharedWith": ["user@example.com", "friend@gmail.com"]
}
```

## 🔒 Segurança

### Implementações de Segurança
- ✅ **Autenticação obrigatória** para todas as operações
- ✅ **Isolamento por usuário** - cada usuário vê apenas suas fotos
- ✅ **Compartilhamento controlado** via lista de emails
- ✅ **Regras de segurança** no Firestore impedem acesso não autorizado
- ✅ **Validação de dados** no frontend e backend

### Fluxo de Segurança
1. **Login** → Firebase Auth valida credenciais
2. **Token JWT** → Gerado automaticamente pelo Firebase
3. **Regras Firestore** → Validam cada operação
4. **Isolamento** → Usuários só acessam seus próprios dados

## 🎯 Funcionalidades por Fase

### ✅ Fase 1 - Fundação
- [x] Configuração do Firebase
- [x] Autenticação com email/senha
- [x] Upload básico de imagens
- [x] Galeria em grid
- [x] Armazenamento no Firestore

### ✅ Fase 2 - Interface
- [x] Design moderno com tema escuro
- [x] Tratamento de erros de imagem
- [x] Responsividade web/mobile
- [x] Modelo de dados estruturado
- [x] UX/UI polida

### ✅ Fase 3 - Funcionalidades Avançadas
- [x] Sistema de deletar fotos
- [x] Sistema de compartilhamento
- [x] Regras de segurança avançadas
- [x] Interface de compartilhamento
- [x] Controle de acesso granular

## 🚧 Limitações Conhecidas

### Técnicas
- **Persistência de imagens**: URLs blob não persistem após recarregar a página web
- **Tamanho de imagens**: Não há compressão automática de imagens
- **Offline**: Não funciona sem conexão com internet
- **Storage**: Usando armazenamento local em vez do Firebase Storage

### UX/UI
- **Preview limitado**: Imagens antigas podem não carregar após reload
- **Sem notificações**: Não há notificações push para compartilhamentos
- **Sem busca**: Não há sistema de busca de fotos

## 🔮 Roadmap Futuro

### 🎯 Próximas Funcionalidades
- [ ] **Firebase Storage** - Implementar upload real para nuvem
- [ ] **Compressão de imagens** - Otimizar tamanho dos arquivos
- [ ] **Sistema de likes** - Curtir fotos compartilhadas
- [ ] **Comentários** - Sistema de comentários nas fotos
- [ ] **Feed compartilhado** - Ver fotos de outros usuários
- [ ] **Notificações push** - Alertas de compartilhamentos

### 🛠️ Melhorias Técnicas
- [ ] **Modo offline** - Sincronização quando voltar online
- [ ] **Cache inteligente** - Armazenamento local otimizado
- [ ] **Lazy loading** - Carregamento sob demanda
- [ ] **Testes automatizados** - Unit e integration tests
- [ ] **CI/CD** - Pipeline de deploy automatizado

### 🎨 Melhorias de Design
- [ ] **Tema claro** - Opção de alternar temas
- [ ] **Animações avançadas** - Transições mais elaboradas
- [ ] **Filtros de foto** - Aplicar filtros nas imagens
- [ ] **Stories** - Funcionalidade similar ao Instagram
- [ ] **Perfil de usuário** - Página de perfil personalizada

## 🤝 Contribuindo

### Como Contribuir
1. **Fork** o projeto
2. **Clone** seu fork: `git clone https://github.com/seu-usuario/Dev-Gram.git`
3. **Crie uma branch**: `git checkout -b feature/MinhaFeature`
4. **Commit** suas mudanças: `git commit -m 'Add: Nova funcionalidade'`
5. **Push** para a branch: `git push origin feature/MinhaFeature`
6. **Abra um Pull Request**

## 👨💻 Autor

**Rafael Lopes**
- 🐙 GitHub: [@lopesmrafael](https://github.com/lopesmrafael)
- 📧 Email: [rafa.lopes.monte@gmail.com](mailto:rafa.lopes.monte@gmail.com)
- 💼 LinkedIn: [Rafael Lopes](www.linkedin.com/in/rafael-lopes-748b60314)

**Luis Otavio**
- 🐙 GitHub: [@LuisOGCosta](https://github.com/LuisOGCosta)
- 📧 Email: [mgluisotavio@gmail.com](mailto:mgluisotavio@gmail.com)
- 💼 LinkedIn: [Luis Otavio](https://www.linkedin.com/in/luis-ot%C3%A1vio-galdino-costa/)

## 📊 Estatísticas do Projeto

![GitHub repo size](https://img.shields.io/github/repo-size/lopesmrafael/Dev-Gram)
![GitHub language count](https://img.shields.io/github/languages/count/lopesmrafael/Dev-Gram)
![GitHub top language](https://img.shields.io/github/languages/top/lopesmrafael/Dev-Gram)
![GitHub last commit](https://img.shields.io/github/last-commit/lopesmrafael/Dev-Gram)

---

⭐ **Se este projeto te ajudou, considere dar uma estrela no repositório!**

🚀 **Desenvolvido com ❤️ usando Flutter e Firebase**