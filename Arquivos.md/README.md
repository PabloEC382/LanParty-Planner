# 🎮 Lan Party Planner

> Uma aplicação em flutter, voltado para organziação de eventos gamers.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev/)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase)](https://supabase.com/)

---

## 📋 Índice

- [Funcionalidades](#-funcionalidades)
- [Arquitetura](#-arquitetura)
- [Tecnologias](#-tecnologias)
- [Como Rodar](#-como-rodar-o-projeto)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Entidades do Domínio](#-entidades-do-domínio)
- [Configuração do Supabase](#-configuração-do-supabase)
- [Screenshots](#-screenshots)
- [Contribuição](#-contribuição)
- [Licença](#-licença)

---

## ✨ Funcionalidades

### 🔐 Onboarding & Privacidade
- **Onboarding Interativo**: Apresentação em 5 etapas com navegação contextual
- **Consentimento LGPD**: Leitura obrigatória de Política de Privacidade e Termos de Uso
- **Marketing Consent**: Opção para receber materiais promocionais
- **Revogação**: Possibilidade de revogar consentimento a qualquer momento
- **Histórico**: Visualização de data e hash do consentimento

### 👤 Perfil de Usuário
- **Cadastro Completo**: Nome, e-mail e foto de perfil
- **Upload de Foto**: Câmera ou galeria com compressão automática
- **Avatar Dinâmico**: Iniciais como fallback quando sem foto
- **Validações**: Email RFC-compliant, nome com limite de caracteres

### 🎯 Gestão de Eventos Gamers
- **Games**: Catálogo de jogos com gêneros, ratings e plataformas
- **Participants**: Cadastro de jogadores com skill level e games preferidos
- **Tournaments**: Organização de torneios com formatos diversos 
- **Venues**: Registro de locais físicos
- **Events**: Criação de eventos com checklist interativo e lista de participantes

### 🗄️ Sincronização com Backend
- **Supabase Integration**: Backend serverless com PostgreSQL
- **Real-time Sync**: Atualização automática de dados
- **Offline-First Ready**: Arquitetura preparada para cache local
- **Row Level Security**: Políticas de segurança configuradas

### 🎨 Design & UX
- **Material 3**: Interface moderna com design system consistente
- **Dark Theme**: Tema escuro otimizado para ambientes gamers
- **Pull-to-Refresh**: Atualização intuitiva de listas
- **Loading States**: Indicadores visuais para operações assíncronas
- **Error Handling**: Mensagens de erro amigáveis

---

## 🏗️ Arquitetura

### Clean Architecture (Simplificada)

```

```

### Padrão Entity ≠ DTO + Mapper

**Entity (Domain Model)**
- Modelo interno da aplicação
- Tipos fortes (Uri, DateTime, Enums)
- Invariantes de domínio (validações, clamps)
- Getters de conveniência para UI
- Exemplo: `skillLevel` clamped entre 1-5

**DTO (Data Transfer Object)**
- Espelha estrutura do backend
- snake_case (image_url, updated_at)
- Tipos primitivos (String, int, double)
- Serialização JSON (fromMap/toMap)

**Mapper**
- Conversão bidirecional única
- Regras de normalização centralizadas
- Sem lógica de negócio
- Métodos: toEntity, toDto, toEntities, toDtos

### Benefícios da Arquitetura
✅ **Isolamento de Mudanças**: Backend pode mudar sem afetar UI  
✅ **Testabilidade**: Mappers testáveis sem rede  
✅ **Segurança**: Validações centralizadas  
✅ **Offline-First**: Cache de DTOs, UI com Entities  

---

## 🛠️ Tecnologias

### Core
- **[Flutter 3.x](https://flutter.dev/)** - Framework multiplataforma
- **[Dart 3.x](https://dart.dev/)** - Linguagem de programação

### Backend & Database
- **[Supabase](https://supabase.com/)** - Backend serverless (PostgreSQL, Auth, Storage)
- **supabase_flutter: ^2.5.0** - Cliente oficial

### State & Storage
- **[shared_preferences](https://pub.dev/packages/shared_preferences)** - Persistência local
- **path_provider** - Acesso a diretórios do sistema

### Media & Images
- **[image_picker](https://pub.dev/packages/image_picker)** - Seleção de imagens
- **[flutter_image_compress](https://pub.dev/packages/flutter_image_compress)** - Compressão de imagens

### Utils
- **[intl](https://pub.dev/packages/intl)** - Formatação de datas e números
- **[crypto](https://pub.dev/packages/crypto)** - Hashing (SHA-256 para consentimentos)
- **[http](https://pub.dev/packages/http)** - Cliente HTTP

### DevOps
- **flutter_launcher_icons** - Geração de ícones

---

## 🚀 Como Rodar o Projeto

### Pré-requisitos
- Flutter SDK 3.x ou superior
- Dart SDK 3.x ou superior
- Conta no [Supabase](https://supabase.com)
- Android Studio / VS Code com extensões Flutter

### 1. Clone o Repositório

```bash
git clone https://github.com/PabloEC382/LanParty-Planner.git
cd LanParty-Planner/lan_party_planner
```

### 2. Instale as Dependências

```bash
flutter pub get
```

### 3. Configure o Supabase

1. Crie um projeto no [Supabase](https://app.supabase.com)
2. Execute o SQL do schema (arquivo `supabase_schema.sql` ou confira no checklist)
3. Copie as credenciais:
   - Project URL
   - Anon/Public Key

4. Atualize `lib/features/core/supabase_config.dart`:

```dart
static const String supabaseUrl = 'SUA_URL_AQUI';
static const String supabaseAnonKey = 'SUA_KEY_AQUI';
```

### 4. Execute o App

```bash
flutter run
```

### 5. (Opcional) Insira Dados de Exemplo

Execute o SQL de seed data no Supabase SQL Editor:
- Veja arquivo `CHECKLIST_PROJETO.md` → seção "Seed Data"

---

## 📂 Estrutura do Projeto

```
lib/
├── core/
│   ├── supabase_config.dart        # Configuração do Supabase
│   └── theme.dart                  # Tema global (cores, estilos)
│
├── features/
│   ├── app/
│   │   └── lan_party_planner_app.dart  # Root widget
│   │
│   ├── consent/                    # Gestão de consentimento
│   │   └── consent_history_screen.dart
│   │
│   ├── home/                       # Tela principal
│   │   ├── home_page.dart
│   │   └── profile_page.dart
│   │
│   ├── onboarding/                 # Fluxo de primeira execução
│   │   ├── onboarding_page.dart
│   │   ├── pages/                  # 5 telas do onboarding
│   │   └── widgets/                # Componentes (dots_indicator)
│   │
│   ├── policies/                   # Leitura de políticas
│   │   ├── policy_viewer_page.dart
│   │   └── listtile_policy_widget.dart
│   │
│   ├── providers/
│   │   ├── domain/
│   │   │   └── entities/           # 5 Entities (Event, Game, etc)
│   │   │
│   │   └── infrastructure/
│   │       ├── dtos/               # 5 DTOs
│   │       ├── mappers/            # 5 Mappers
│   │       ├── datasources/        # 5 Remote DataSources
│   │       └── repositories/       # 5 Repositories
│   │
│   ├── screens/                    # Telas de listagem e formulários
│   │   ├── games_list_screen.dart
│   │   ├── participants_list_screen.dart
│   │   ├── tournaments_list_screen.dart
│   │   ├── venues_list_screen.dart
│   │   └── events_list_screen.dart
│   │
│   └── splashscreen/
│       └── splashscreen_page.dart
│
├── services/
│   ├── preferences_keys.dart       # Chaves do SharedPreferences
│   └── shared_preferences_services.dart
│
└── main.dart                       # Entry point

assets/
├── PNGs/
│   ├── logoIA.png
│   └── logoIASemfundo.png
├── privacidade.md
└── termos.md
```

---

## 🎯 Entidades do Domínio

### 1️⃣ Event (Evento)
```dart
- id, name, eventDate
- checklist: Map<String, bool> 
- attendees: List<String> 
- Getters: summary, isComplete, attendeeCount
```

### 2️⃣ Game (Jogo)
```dart
- id, title, genre, description
- minPlayers, maxPlayers
- platforms: Set<String>
- averageRating (0-5), totalMatches
- Getters: playerRange, ratingDisplay, isPopular
```

### 3️⃣ Participant (Participante)
```dart
- id, name, email, nickname
- avatarUri, skillLevel (1-5)
- preferredGames: Set<String>
- isPremium
- Getters: displayName, skillLevelText, badge
```

### 4️⃣ Tournament (Torneio)
```dart
- id, name, gameId, description
- format: TournamentFormat (enum)
- status: TournamentStatus (enum)
- maxParticipants, currentParticipants
- prizePool, startDate, endDate
- Getters: statusText, prizeDisplay, canRegister
```

### 5️⃣ Venue (Local)
```dart
- id, name, address, city, state
- latitude, longitude (coordenadas)
- capacity, contactInfo, notes
- Getters: fullAddress, mapsUrl, capacityCategory
```

---

## 🗄️ Configuração do Supabase

### Schema Básico

Principais tabelas criadas:

```sql
-- Events
CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    event_date TIMESTAMPTZ NOT NULL,
    checklist JSONB DEFAULT '{}',
    attendees TEXT[] DEFAULT '{}',
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Games (similar structure)
-- Participants (similar structure)
-- Tournaments (similar structure)
-- Venues (similar structure)
```

### Recursos Configurados
✅ **Triggers**: Auto-update de `updated_at`  
✅ **Índices**: Otimização de queries  
✅ **RLS**: Row Level Security habilitado  
✅ **Seed Data**: Dados de exemplo para testes  

---

### Principais Telas
- Splash Screen
- Onboarding (5 etapas)
- Home com Drawer Menu
- Perfil com Upload de Foto
- Games List + Form (CRUD completo)
- Lists de Participants, Tournaments, Venues, Events

---

## 🧪 Testes

### Testes Manuais Realizados
✅ Onboarding completo  
✅ Skip e navegação contextual  
✅ Leitura de políticas com scroll obrigatório  
✅ Upload e compressão de foto de perfil 
✅ Listagem de todas as entidades  
✅ Pull-to-refresh  
✅ Error handling  

---

## 🔮 Roadmap

### ✅ Versão 1.0 (Atual)
- Arquitetura Entity-DTO-Mapper completa
- Supabase integrado
- Onboarding e perfil
- Games CRUD funcional
- 5 entidades com listagens

### 🚧 Versão 1.1 (Próxima)
- [ ] CRUD completo de todas as entidades
- [ ] Cache local (Isar/Drift)
- [ ] Busca e filtros
- [ ] Modo offline

### 🔭 Versão 2.0 (Futuro)
- [ ] Autenticação de usuários
- [ ] Notificações push
- [ ] Integração com Google Maps
- [ ] Upload de imagens para Supabase Storage
- [ ] Chat em tempo real

---

## 🤝 Contribuição

Contribuições são bem-vindas! Para contribuir:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

### Guidelines
- Seguir a arquitetura Entity-DTO-Mapper
- Manter consistência de código (dartfmt)
- Adicionar comentários em código complexo
- Testar manualmente antes do PR

---

## 📄 Licença

Este projeto **não possui licença** definida no momento.

---

## 👨‍💻 Autor

**Pablo Emanuel Cechim de Lima**

- GitHub: [@PabloEC382](https://github.com/PabloEC382)
- Projeto desenvolvido como parte do curso de **Desenvolvimento de Aplicações (Flutter)**

---

## 📚 Documentação Adicional

- **[CHECKLIST_PROJETO.md](CHECKLIST_PROJETO.md)** - Checklist completo de implementação
- **[Supabase Docs](https://supabase.com/docs)** - Documentação oficial do Supabase
- **[Flutter Docs](https://docs.flutter.dev/)** - Documentação oficial do Flutter

---