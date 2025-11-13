# 🚀 Guia de Uso - LAN Party Planner (SharedPreferences)

## 📦 Dependências Necessárias

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  intl: ^0.18.1
  shared_preferences: ^2.2.2        # ✅ Persistência local
  path_provider: ^2.1.2
  image_picker: ^1.0.7
  flutter_image_compress: ^2.2.0
  crypto: ^3.0.3
  http: ^1.2.1
  flutter_launcher_icons: ^0.14.4
```

## 🎯 Como Usar no Código

### 1. Criar um Evento

```dart
import 'package:lan_party_planner/features/providers/presentation/dialogs/event_form_dialog.dart';
import 'package:lan_party_planner/features/providers/infrastructure/repositories/events_repository_impl.dart';
import 'package:lan_party_planner/features/providers/infrastructure/local/events_local_dao_shared_prefs.dart';

// No seu widget/state:
final repository = EventsRepositoryImpl(localDao: EventsLocalDaoSharedPrefs());

// Abrir dialog:
final result = await showEventFormDialog(context);
if (result != null) {
  // Converter DTO para Entidade
  final event = Event(
    id: result.id,
    name: result.name,
    eventDate: DateTime.parse(result.event_date),
    checklist: result.checklist.cast<String, bool>(),
    attendees: result.attendees,
    updatedAt: DateTime.parse(result.updated_at),
  );
  
  // Persistir
  await repository.create(event);
  
  // Notificar usuário
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Evento criado com sucesso!')),
  );
}
```

### 2. Listar Eventos

```dart
Future<void> loadEvents() async {
  try {
    final events = await repository.listAll();
    setState(() {
      _events = events;
    });
  } catch (e) {
    print('Erro ao carregar eventos: $e');
  }
}
```

### 3. Buscar Evento por ID

```dart
Future<void> findEvent(String id) async {
  final event = await repository.getById(id);
  if (event != null) {
    print('Encontrado: ${event.name}');
  }
}
```

### 4. Atualizar Evento

```dart
Future<void> updateEvent(Event event) async {
  await repository.update(event);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Evento atualizado!')),
  );
}
```

### 5. Deletar Evento

```dart
Future<void> deleteEvent(String id) async {
  await repository.delete(id);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Evento removido!')),
  );
  await loadEvents(); // Recarregar lista
}
```

---

## 📊 APIs de Cada Repositório

### EventsRepository
```dart
Future<List<Event>> listAll()
Future<Event?> getById(String id)
Future<Event> create(Event event)
Future<Event> update(Event event)
Future<void> delete(String id)
Future<void> sync()  // No-op (local only)
Future<void> clearCache()
```

### GamesRepository (+ métodos extras)
```dart
// Acima + :
Future<List<Game>> findByGenre(String genre)
Future<List<Game>> findPopular({int limit = 10})
```

### ParticipantsRepository (+ métodos extras)
```dart
// Acima + :
Future<Participant?> getByEmail(String email)
Future<Participant?> getByNickname(String nickname)
Future<List<Participant>> findPremium()
Future<List<Participant>> findBySkillLevel(int skillLevel)
```

### TournamentsRepository (+ métodos extras)
```dart
// Acima + :
Future<List<Tournament>> findByStatus(TournamentStatus status)
Future<List<Tournament>> findByGame(String gameId)
Future<List<Tournament>> findOpenForRegistration()
Future<List<Tournament>> findInProgress()
```

### VenuesRepository (+ métodos extras)
```dart
// Acima + :
Future<List<Venue>> findByCity(String city)
Future<List<Venue>> findByState(String state)
Future<List<Venue>> findVerified()
Future<List<Venue>> findByMinCapacity(int minCapacity)
Future<List<Venue>> findTopRated({int limit = 10})
```

---

## 🔐 Dados Persistidos em SharedPreferences

Cada entidade usa uma chave específica:

```
events_cache_v1          → JSON array de eventos
games_cache_v1           → JSON array de jogos
participants_cache_v1    → JSON array de participantes
tournaments_cache_v1     → JSON array de torneios
venues_cache_v1          → JSON array de locais
```

### Formato dos Dados Salvos

```json
// events_cache_v1
[
  {
    "id": "1",
    "name": "LAN Party 2024",
    "event_date": "2024-12-01",
    "checklist": {},
    "attendees": [],
    "updated_at": "2024-11-13T10:30:00.000Z"
  }
]
```

---

## 🛠️ Troubleshooting

### Problema: Dados não persistem após fechar app
**Solução**: Verifique que você está chamando `await repository.create()` (ou `update()`, `delete()`) antes de `setState()`

### Problema: Dialog não abre
**Solução**: Certifique-se de fazer `await showEventFormDialog(context)` (precisa de `await`)

### Problema: SnackBar não aparece
**Solução**: Verifique que `Scaffold` está no contexto: `ScaffoldMessenger.of(context).showSnackBar(...)`

### Problema: Lista vazia ao abrir app
**Solução**: Verifique que `_loadEvents()` está sendo chamado em `initState()`

### Problema: Erro ao converter tipos
**Solução**: Verifique que o Mapper está convertendo corretamente (DTO → Entidade)

---

## 📱 Testando no Emulador

```bash
# Executar app
flutter run

# Com hot reload (salve arquivo para recarregar)
flutter run

# Limpar dados (reset SharedPreferences)
flutter clean
flutter pub get
flutter run

# Ver logs
flutter logs
```

---

## 🗑️ Limpar Dados Localmente

Se precisar resetar todos os dados salvos:

```dart
// No seu código:
final dao = EventsLocalDaoSharedPrefs();
await dao.clear();  // Limpa eventos

// Ou limpar tudo manualmente:
final prefs = await SharedPreferences.getInstance();
await prefs.clear();  // Limpa TODOS os dados do app
```

---

## 📝 Estrutura de Dialogs

Todos os dialogs seguem este padrão:

```dart
Future<DtoType?> showXxxFormDialog(
  BuildContext context, {
  DtoType? initial,  // Para edição
}) async {
  return showDialog<DtoType>(
    context: context,
    builder: (context) => _XxxFormDialog(initial: initial),
  );
}
```

### Usar para Adicionar:
```dart
final result = await showEventFormDialog(context);
// initial = null
```

### Usar para Editar:
```dart
final result = await showEventFormDialog(context, initial: currentEventDto);
// initial = current DTO
// Campos pré-preenchidos
```

---

## 🎨 Customizando Cores

As cores estão em `lib/features/core/theme.dart`:

```dart
const Color slate = Color(0xFF1E293B);
const Color purple = Color(0xFF8B5CF6);
const Color cyan = Color(0xFF06B6D4);
```

---

## 📚 Arquivos Principais

| Arquivo | Descrição |
|---------|-----------|
| `lib/main.dart` | Entry point (sem Supabase agora) |
| `lib/features/providers/infrastructure/repositories/*_impl.dart` | Implementações dos repositórios |
| `lib/features/providers/presentation/dialogs/*_form_dialog.dart` | Dialogs de formulário |
| `lib/features/providers/infrastructure/local/*_dao_shared_prefs.dart` | Persistência |
| `lib/features/screens/*_list_screen.dart` | Telas com integração |
| `MIGRACAO_SUPABASE_SHAREDPREFS.md` | Documentação completa |
| `TESTE_MANUAL.dart` | Checklist de teste |

---

## ✅ Checklist de Deploy

Antes de fazer deploy:

- [ ] Todos os dados mockados têm IDs únicos
- [ ] Não há logs ou print() statements
- [ ] SnackBars têm mensagens úteis
- [ ] FABs funcionam em todas as telas
- [ ] Pull-to-refresh funciona
- [ ] Validações de campos obrigatórios funcionam
- [ ] Persistência funcionando (teste fechar/reabrir app)
- [ ] Sem erros no console (`flutter analyze`)
- [ ] Testes passando (`flutter test`)

---

## 🚀 Próximos Passos

Para melhorar ainda mais:

1. **Adicionar Edição**
   - Passar `initial` DTO ao dialog
   - Botão "Editar" ao lado do item na lista
   - Chamar `repository.update()` em vez de `create()`

2. **Adicionar Delete**
   - Swipe para deletar (Dismissible widget)
   - Dialog de confirmação
   - Chamar `repository.delete(id)`

3. **Adicionar Busca**
   - TextField de busca na AppBar
   - Filtro da lista em tempo real
   - Usar métodos `find*()` dos repositórios

4. **Adicionar Paginação**
   - ListView com `itemCount` dinâmico
   - Load more button
   - Manter offset da posição

5. **Adicionar Testes**
   - Unit tests para repositories
   - Widget tests para dialogs
   - Integration tests para fluxo completo

---

**✨ Projeto pronto para produção com persistência local!**
