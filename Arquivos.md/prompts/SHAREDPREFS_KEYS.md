# 📦 Referência de Chaves SharedPreferences

## Mapeamento de Dados Persistidos

Cada entidade é armazenada no SharedPreferences com uma chave específica em formato JSON.

---

## 🎮 Events (Eventos)

```dart
// Chave de armazenamento
const String eventsKey = 'events_cache_v1';

// Estrutura armazenada
[
  {
    "id": "1735689600000",
    "name": "LAN Party 2024",
    "event_date": "2024-12-31",
    "created_at": "2024-12-31T12:00:00.000Z"
  }
]
```

**Como acessar diretamente:**
```dart
import 'package:shared_preferences/shared_preferences.dart';

final prefs = await SharedPreferences.getInstance();
final eventJson = prefs.getString('events_cache_v1');
final List<dynamic> eventsList = jsonDecode(eventJson ?? '[]');
```

---

## 🎯 Games (Jogos)

```dart
// Chave de armazenamento
const String gamesKey = 'games_cache_v1';

// Estrutura armazenada
[
  {
    "id": "1735689600000",
    "title": "Counter-Strike 2",
    "genre": "FPS",
    "description": "Tactical shooter",
    "min_players": 2,
    "max_players": 10,
    "cover_image_url": "https://...",
    "total_matches": 42
  }
]
```

**Métodos de repositório específicos:**
```dart
// Buscar jogos por gênero
repository.findByGenre('FPS')

// Buscar top 10 jogos mais populares
repository.findPopular(limit: 10)
```

---

## 👥 Participants (Participantes)

```dart
// Chave de armazenamento
const String participantsKey = 'participants_cache_v1';

// Estrutura armazenada
[
  {
    "id": "1735689600000",
    "name": "João Silva",
    "email": "joao@example.com",
    "nickname": "JoaoGamer",
    "skill_level": 8,
    "avatar_url": "https://...",
    "isPremium": true,
    "created_at": "2024-12-31T12:00:00.000Z"
  }
]
```

**Métodos de repositório específicos:**
```dart
// Buscar por email
repository.getByEmail('joao@example.com')

// Buscar por nickname
repository.getByNickname('JoaoGamer')

// Listar jogadores premium
repository.findPremium()

// Filtrar por skill level (1-10)
repository.findBySkillLevel(8)
```

---

## 🏆 Tournaments (Torneios)

```dart
// Chave de armazenamento
const String tournamentsKey = 'tournaments_cache_v1';

// Estrutura armazenada
[
  {
    "id": "1735689600000",
    "name": "Winter Championship 2024",
    "game_id": "1735689600000",
    "description": "Maior torneio do ano",
    "format": "Double Elimination",
    "status": "In Progress",
    "max_participants": 64,
    "prize_pool": 10000.0,
    "start_date": "2024-12-15",
    "created_at": "2024-12-01T12:00:00.000Z"
  }
]
```

**Enums utilizados:**
```dart
enum TournamentFormat {
  single,       // Single Elimination
  double,       // Double Elimination
  roundRobin,   // Round Robin
  swiss         // Swiss System
}

enum TournamentStatus {
  draft,              // Rascunho
  registration,       // Aberto para inscrição
  inProgress,         // Em andamento
  finished,           // Finalizado
  cancelled           // Cancelado
}
```

**Métodos de repositório específicos:**
```dart
// Buscar por status
repository.findByStatus(TournamentStatus.inProgress)

// Buscar por jogo
repository.findByGame('game_id_123')

// Torneios abertos para inscrição
repository.findOpenForRegistration()

// Torneios em andamento
repository.findInProgress()
```

---

## 🏢 Venues (Locais)

```dart
// Chave de armazenamento
const String venuesKey = 'venues_cache_v1';

// Estrutura armazenada
[
  {
    "id": "1735689600000",
    "name": "Arena Gaming SP",
    "city": "São Paulo",
    "address": "Avenida Paulista, 1000",
    "state": "SP",
    "zip_code": "01311-100",
    "latitude": -23.5505,
    "longitude": -46.6333,
    "capacity": 500,
    "price_per_hour": 250.0,
    "phone": "(11) 9999-9999",
    "website_url": "https://arenasp.com.br",
    "is_verified": true,
    "rating": 4.8,
    "created_at": "2024-12-31T12:00:00.000Z"
  }
]
```

**Métodos de repositório específicos:**
```dart
// Filtrar por cidade
repository.findByCity('São Paulo')

// Filtrar por estado
repository.findByState('SP')

// Listar locais verificados
repository.findVerified()

// Filtrar por capacidade mínima
repository.findByMinCapacity(100)

// Top rated locais (limit = 5 por padrão)
repository.findTopRated(limit: 5)
```

---

## 🔍 Como Inspecionar Dados Persistidos

### Método 1: Usando a Tela (Recomendado)
Abra a app e navegue para cada tela para ver os dados.

### Método 2: Console (Debug)
```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<void> printAllSharedPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  
  // Events
  print('=== EVENTS ===');
  final eventsJson = prefs.getString('events_cache_v1');
  print(jsonDecode(eventsJson ?? '[]'));
  
  // Games
  print('=== GAMES ===');
  final gamesJson = prefs.getString('games_cache_v1');
  print(jsonDecode(gamesJson ?? '[]'));
  
  // Participants
  print('=== PARTICIPANTS ===');
  final participantsJson = prefs.getString('participants_cache_v1');
  print(jsonDecode(participantsJson ?? '[]'));
  
  // Tournaments
  print('=== TOURNAMENTS ===');
  final tournamentsJson = prefs.getString('tournaments_cache_v1');
  print(jsonDecode(tournamentsJson ?? '[]'));
  
  // Venues
  print('=== VENUES ===');
  final venuesJson = prefs.getString('venues_cache_v1');
  print(jsonDecode(venuesJson ?? '[]'));
}

// Adicionar em main.dart para debug:
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await printAllSharedPreferences();
  runApp(const LanPartyPlannerApp());
}
```

### Método 3: Android Studio (Device Explorer)
```
1. Abra Device Explorer (Menu → Tools → Device Explorer)
2. Navegue até: /data/data/com.example.lan_party_planner/shared_prefs/
3. Procure por: Flutter.plist (iOS) ou SharedPreferences XML (Android)
```

---

## 🧪 Testando Persistência

### Teste 1: Criar e Persistir
```dart
// 1. Abra a tela de eventos
// 2. Clique FAB
// 3. Preencha nome: "Evento Teste"
// 4. Preencha data: "2024-12-31"
// 5. Clique "Adicionar"
// 6. Verifique SnackBar: "Evento adicionado com sucesso!"
// 7. Verifique que evento aparece na lista
```

### Teste 2: Fechar e Reabrir
```dart
// 1. Após criar evento (acima)
// 2. Feche o app completamente
// 3. Reabra o app
// 4. Navegue para tela de eventos
// 5. Confirme que evento ainda está lá ✅ PERSISTÊNCIA FUNCIONANDO
```

### Teste 3: Limpar Cache
```dart
import 'package:shared_preferences/shared_preferences.dart';

Future<void> clearAllData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  print('Todos os dados foram limpos!');
}
```

---

## 📊 Tamanho Típico dos Dados

| Entidade | Tamanho por item | Cap. Recomendada |
|----------|------------------|------------------|
| Event | ~150 bytes | 5,000+ eventos |
| Game | ~200 bytes | 5,000+ jogos |
| Participant | ~250 bytes | 5,000+ participantes |
| Tournament | ~300 bytes | 3,000+ torneios |
| Venue | ~350 bytes | 2,000+ locais |

**Limite total do SharedPreferences:** ~10 MB em Flutter

---

## ⚡ Otimizações Futuras

### 1. Índices para Busca Rápida
```dart
// Ao invés de buscar toda lista:
// repository.findByCity('São Paulo')

// Podia usar índices:
class VenuesRepositoryImpl {
  Map<String, List<Venue>> _cityIndex = {};
  
  Future<List<Venue>> findByCity(String city) async {
    return _cityIndex[city] ?? [];
  }
}
```

### 2. Paginação
```dart
Future<List<Venue>> listAll({int page = 1, int pageSize = 20}) async {
  final dtos = await _localDao.listAll();
  final start = (page - 1) * pageSize;
  final end = start + pageSize;
  return dtos
    .sublist(start, end.clamp(0, dtos.length))
    .map((dto) => VenueMapper.toEntity(dto))
    .toList();
}
```

### 3. Sincronização com Backend
```dart
Future<void> syncWithServer() async {
  // 1. Buscar dados locais
  final localVenues = await listAll();
  
  // 2. Enviar para servidor (quando disponível)
  // await apiClient.uploadVenues(localVenues);
  
  // 3. Buscar atualizações
  // final remoteVenues = await apiClient.getVenues();
  
  // 4. Mesclar / Atualizar local
  // await _syncAndUpdate(remoteVenues);
}
```

---

## 🔐 Segurança e Privacy

**Dados Sensíveis:**
- ❌ NÃO armazene senhas em SharedPreferences
- ❌ NÃO armazene tokens de autenticação
- ⚠️ CUIDADO com dados pessoais (emails, nomes)

**Recomendações:**
- ✅ Use flutter_secure_storage para dados sensíveis
- ✅ Implemente encriptação se necessário
- ✅ Realize limpeza de dados quando usuário fazer logout

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

// Armazenar de forma segura
await storage.write(
  key: 'user_auth_token',
  value: 'seu_token_secreto',
);

// Recuperar
final token = await storage.read(key: 'user_auth_token');
```

---

## 📞 Troubleshooting

**Problema: Dados não aparecem após criar**
- Verifique se `upsertAll()` foi chamado no DAO
- Confirme que chave de SharedPreferences está correta
- Verifique console para exceções JSON

**Problema: Dados sumiram após fechar app**
- Verifique se `upsertAll()` chamou `prefs.setString()`
- Confirme que `await` foi usado em operações async
- Tente limpar cache do app e testar novamente

**Problema: Muitos dados / App fica lento**
- Implemente paginação
- Implemente índices para buscas
- Considere migrar para SQLite/Hive para grandes volumes

---

## 📚 Referências

- **SharedPreferences Docs:** https://pub.dev/packages/shared_preferences
- **Flutter Storage Options:** https://docs.flutter.dev/development/data-and-backend/data
- **Security Best Practices:** https://docs.flutter.dev/development/data-and-backend/security

---

**Gerado em:** 2024
**Versão:** 1.0
**Status:** ✅ Documentação Completa
