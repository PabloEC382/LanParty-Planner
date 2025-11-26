# Clean Architecture - Guia de Reorganização do Projeto

## 📋 Análise Atual

O projeto está parcialmente seguindo Clean Architecture com a pasta `providers` bem estruturada, mas há inconsistências em outras áreas.

## 🏗️ Estrutura Após Reorganização

```
lib/
├── core/                                    # Utilitários compartilhados
│   ├── theme.dart
│   └── constants/
│
├── features/                                # Cada feature segue Clean Architecture
│
│   ├── events/                              # Feature: Gerenciamento de Eventos
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── event.dart
│   │   │   └── repositories/
│   │   │       └── event_repository.dart
│   │   ├── infrastructure/
│   │   │   ├── dtos/
│   │   │   │   └── event_dto.dart
│   │   │   ├── local/
│   │   │   │   └── events_local_dao_shared_prefs.dart
│   │   │   ├── mappers/
│   │   │   │   └── event_mapper.dart
│   │   │   └── repositories/
│   │   │       └── events_repository_impl.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── events_list_screen.dart
│   │       │   └── upcoming_events_screen.dart
│   │       ├── dialogs/
│   │       │   ├── event_form_dialog.dart
│   │       │   ├── event_actions_dialog.dart
│   │       │   └── event_detail_screen.dart
│   │       └── widgets/
│   │           └── (event_card.dart, etc)
│   │
│   ├── games/                               # Feature: Gerenciamento de Jogos
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── game.dart
│   │   │   └── repositories/
│   │   │       └── game_repository.dart
│   │   ├── infrastructure/
│   │   │   ├── dtos/
│   │   │   ├── local/
│   │   │   ├── mappers/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── games_list_screen.dart
│   │       ├── dialogs/
│   │       └── widgets/
│   │
│   ├── venues/                              # Feature: Gerenciamento de Locais
│   │   ├── domain/
│   │   ├── infrastructure/
│   │   └── presentation/
│   │
│   ├── participants/                        # Feature: Gerenciamento de Participantes
│   │   ├── domain/
│   │   ├── infrastructure/
│   │   └── presentation/
│   │
│   ├── tournaments/                         # Feature: Gerenciamento de Torneios
│   │   ├── domain/
│   │   ├── infrastructure/
│   │   └── presentation/
│   │
│   ├── home/                                # Feature: Home/Dashboard
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── (se necessário)
│   │   ├── infrastructure/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   ├── home_page.dart
│   │   │   │   ├── tutorial_screen.dart
│   │   │   │   └── profile_page.dart
│   │   │   └── widgets/
│   │   │       └── onboarding_tooltip.dart
│   │
│   ├── consent/                             # Feature: Consentimento
│   │   ├── domain/
│   │   ├── infrastructure/
│   │   └── presentation/
│   │
│   ├── onboarding/                          # Feature: Onboarding
│   │   ├── domain/
│   │   ├── infrastructure/
│   │   └── presentation/
│   │       ├── pages/
│   │       └── widgets/
│   │
│   ├── policies/                            # Feature: Políticas
│   │   ├── domain/
│   │   ├── infrastructure/
│   │   └── presentation/
│   │
│   └── splashscreen/                        # Feature: SplashScreen
│       ├── domain/
│       ├── infrastructure/
│       └── presentation/
│
└── services/                                # Serviços reutilizáveis
    ├── shared_preferences_services.dart
    └── preferences_keys.dart
```

## 🔄 Mapeamento de Arquivos

### Arquivos que serão movidos:

**Events Feature:**
- `providers/domain/entities/event.dart` → `events/domain/entities/event.dart`
- `providers/domain/repositories/event_repository.dart` → `events/domain/repositories/event_repository.dart`
- `providers/infrastructure/dtos/event_dto.dart` → `events/infrastructure/dtos/event_dto.dart`
- `providers/infrastructure/local/events_local_dao_shared_prefs.dart` → `events/infrastructure/local/events_local_dao_shared_prefs.dart`
- `providers/infrastructure/mappers/event_mapper.dart` → `events/infrastructure/mappers/event_mapper.dart`
- `providers/infrastructure/repositories/events_repository_impl.dart` → `events/infrastructure/repositories/events_repository_impl.dart`
- `screens/events_list_screen.dart` → `events/presentation/pages/events_list_screen.dart`
- `providers/presentation/dialogs/event_form_dialog.dart` → `events/presentation/dialogs/event_form_dialog.dart`
- `providers/presentation/dialogs/event_actions_dialog.dart` → `events/presentation/dialogs/event_actions_dialog.dart`
- `providers/presentation/screens/event_detail_screen.dart` → `events/presentation/pages/event_detail_screen.dart`

**Games Feature:**
- `providers/domain/entities/game.dart` → `games/domain/entities/game.dart`
- `providers/domain/repositories/game_repository.dart` → `games/domain/repositories/game_repository.dart`
- `providers/infrastructure/dtos/game_dto.dart` → `games/infrastructure/dtos/game_dto.dart`
- `providers/infrastructure/local/games_local_dao_shared_prefs.dart` → `games/infrastructure/local/games_local_dao_shared_prefs.dart`
- `providers/infrastructure/mappers/game_mapper.dart` → `games/infrastructure/mappers/game_mapper.dart`
- `providers/infrastructure/repositories/games_repository_impl.dart` → `games/infrastructure/repositories/games_repository_impl.dart`
- `screens/games_list_screen.dart` → `games/presentation/pages/games_list_screen.dart`
- `providers/presentation/dialogs/game_form_dialog.dart` → `games/presentation/dialogs/game_form_dialog.dart`
- `providers/presentation/dialogs/game_actions_dialog.dart` → `games/presentation/dialogs/game_actions_dialog.dart`
- `providers/presentation/screens/game_detail_screen.dart` → `games/presentation/pages/game_detail_screen.dart`

**Venues Feature:**
- `providers/domain/entities/venue.dart` → `venues/domain/entities/venue.dart`
- `providers/infrastructure/dtos/venue_dto.dart` → `venues/infrastructure/dtos/venue_dto.dart`
- `providers/infrastructure/local/venues_local_dao_shared_prefs.dart` → `venues/infrastructure/local/venues_local_dao_shared_prefs.dart`
- `providers/infrastructure/mappers/venue_mapper.dart` → `venues/infrastructure/mappers/venue_mapper.dart`
- `providers/infrastructure/repositories/venues_repository_impl.dart` → `venues/infrastructure/repositories/venues_repository_impl.dart`
- `screens/venues_list_screen.dart` → `venues/presentation/pages/venues_list_screen.dart`
- `providers/presentation/dialogs/venue_form_dialog.dart` → `venues/presentation/dialogs/venue_form_dialog.dart`
- `providers/presentation/dialogs/venue_actions_dialog.dart` → `venues/presentation/dialogs/venue_actions_dialog.dart`
- `providers/presentation/screens/venue_detail_screen.dart` → `venues/presentation/pages/venue_detail_screen.dart`

**Participants Feature:**
- `providers/domain/entities/participant.dart` → `participants/domain/entities/participant.dart`
- Similar pattern...

**Tournaments Feature:**
- `providers/domain/entities/tournament.dart` → `tournaments/domain/entities/tournament.dart`
- Similar pattern...

**Home Feature:**
- `home/home_page.dart` → `home/presentation/pages/home_page.dart`
- `home/profile_page.dart` → `home/presentation/pages/profile_page.dart`
- `home/tutorial_screen.dart` → `home/presentation/pages/tutorial_screen.dart`
- `home/upcoming_events_screen.dart` → `home/presentation/pages/upcoming_events_screen.dart`
- `home/onboarding_tooltip.dart` → `home/presentation/widgets/onboarding_tooltip.dart`

## ✅ Camadas Explicadas

### Domain Layer (Regras de Negócio)
- **Entities**: Modelos core do domínio (imutáveis, sem dependências)
- **Repositories (Interfaces)**: Contratos de acesso aos dados

### Infrastructure Layer (Implementação)
- **DTOs**: Modelos para serialização/deserialização
- **Local**: Implementações locais (SharedPreferences, Database)
- **Mappers**: Convertem entre Entities e DTOs
- **Repositories (Implementações)**: Implementam os contratos do domain

### Presentation Layer (Interface)
- **Pages**: Telas principais (StatefulWidgets)
- **Dialogs**: Componentes modais
- **Widgets**: Componentes reutilizáveis

## 🔧 Próximos Passos

1. ✅ Criar estrutura de diretórios (já feito)
2. ⏳ Mover arquivos para novas locações
3. ⏳ Atualizar imports em todos os arquivos
4. ⏳ Remover pasta `providers` (consolidar em features específicas)
5. ⏳ Testar compilação

## 📝 Notas

- Todos os arquivos serão preservados (SEM REMOVER NADA)
- Apenas serão organizados conforme Clean Architecture
- Os imports serão atualizados automaticamente
- A pasta `providers` será um agregador temporário até consolidação completa
