# 📋 Agent List Prompt - Especificação de Listagem de Provedores

## 🎯 Objetivo

Gerar uma especificação de **listagem paginada e filtrável** de provedores (providers) que pode ser aplicada a qualquer entidade do projeto (Event, Game, Participant, Tournament, Venue).

---

## ⚙️ Parâmetros Configuráveis

```dart
// Substitua estes valores conforme a entidade
ENTITY_SINGULAR: "Provedor"              // Ex: "Evento", "Jogo", "Participante"
ENTITY_PLURAL: "provedores"              // Ex: "eventos", "jogos", "participantes"
DTO_CLASS: "ProviderDto"                 // Ex: "EventDto", "GameDto", etc.
FEATURE_FOLDER: "providers"              // Ex: "providers"
PAGE_DEFAULT: 1
PAGE_SIZE_DEFAULT: 20
MAX_PAGE_SIZE: 100
SORT_BY_DEFAULT: "name"
INCLUDE_HINT: "contacts,addresses"       // Relacionamentos opcionais
```

---

## 📥 Entradas (Inputs)

### Query Parameters

| Parâmetro | Tipo | Obrigatório | Padrão | Descrição |
|-----------|------|------------|--------|-----------|
| `filters` | Object | Não | `{}` | Critérios de busca avançada |
| `filters.q` | String | Não | - | Busca por texto (busca em nome, email, etc) |
| `filters.status` | String | Não | - | Filtrar por status (active, inactive, etc) |
| `page` | Integer | Não | 1 | Número da página (começa em 1) |
| `pageSize` | Integer | Não | 20 | Itens por página (max: 100) |
| `sortBy` | String | Não | "name" | Campo para ordenação |
| `sortDir` | String | Não | "asc" | Direção: "asc" ou "desc" |
| `include` | Array<String> | Não | `[]` | Relacionamentos a incluir (ex: `["contacts", "addresses"]`) |

### Exemplos de Uso

```dart
// Listagem padrão (primeira página, 20 itens, ordenado por nome)
GET /providers
  → Response: 20 itens, página 1 de N, ordenados por nome (asc)

// Busca com filtro
GET /providers?filters.q=farmacia&filters.status=active
  → Response: Farmácias ativas contendo "farmacia" no nome

// Paginação
GET /providers?page=3&pageSize=50
  → Response: Itens 101-150 (página 3 com 50 por página)

// Ordenação customizada
GET /providers?sortBy=rating&sortDir=desc
  → Response: Ordenado por rating (maior primeiro)

// Com relacionamentos
GET /providers?include=contacts,addresses
  → Response: Inclui dados de contato e endereço completos
```

---

## 📤 Saída (Response)

### Estrutura Geral

```json
{
  "meta": {
    "total": 124,
    "page": 1,
    "pageSize": 20,
    "totalPages": 7,
    "hasNextPage": true,
    "hasPrevPage": false
  },
  "filtersApplied": {
    "q": null,
    "status": null,
    "sortBy": "name",
    "sortDir": "asc",
    "include": []
  },
  "data": [
    // Lista de provedores
  ]
}
```

---

## 📊 Contrato de Dados (DTO)

### Campos Padrão (sempre incluídos)

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",     // UUID
  "name": "Farmácia São José",                       // String
  "status": "active",                                // "active" | "inactive" | "pending"
  "createdAt": "2024-03-12T10:15:30Z",              // ISO8601
  "updatedAt": "2025-07-02T08:12:00Z"               // ISO8601
}
```

### Campos Opcionais (sempre incluídos se existentes)

```json
{
  "rating": 4.7,                                     // Double (0-5)
  "distance_km": 1.4,                                // Double (apenas para busca geolocalizada)
  "image_url": "https://cdn.example.com/images/...", // String (URL)
  "taxId": "12.345.*** / 0001-23",                  // String (mascarado)
  "description": "Farmácia 24h com entrega",        // String
  "total_matches": 42                                // Integer (apenas para games)
}
```

### Campos de Relacionamento (incluídos apenas se `include` solicitado)

```json
{
  "contact": {
    "email": "contato@fsj.com.br",
    "phone": "+55 (11) 9****-1234"                  // Mascarado
  },
  "address": {
    "street": "Av. Brasil, 123",
    "city": "São Paulo",
    "state": "SP",
    "zip": "01234-000"
  },
  "tags": ["24h", "delivery", "farmácia"],
  "metadata": {
    "lastOrderDate": "2025-07-01T19:30:00Z",
    "totalOrders": 156,
    "averageOrderValue": 120.50
  }
}
```

---

## 📋 Exemplo Completo de Resposta

### Request
```
GET /providers?filters.q=farm&filters.status=active&page=1&pageSize=20&sortBy=rating&sortDir=desc&include=contact,address
```

### Response 200 OK
```json
{
  "meta": {
    "total": 3,
    "page": 1,
    "pageSize": 20,
    "totalPages": 1,
    "hasNextPage": false,
    "hasPrevPage": false
  },
  "filtersApplied": {
    "q": "farm",
    "status": "active",
    "sortBy": "rating",
    "sortDir": "desc",
    "include": ["contact", "address"]
  },
  "data": [
    {
      "id": "b6f8c1f2-3d2a-4a9e-9f6b-1a2b3c4d5e6f",
      "name": "Farmácia São José",
      "rating": 4.9,
      "distance_km": 1.4,
      "image_url": "https://cdn.example.com/images/fsj.png",
      "taxId": "12.345.*** / 0001-23",
      "status": "active",
      "description": "Farmácia 24h com entrega",
      "createdAt": "2024-03-12T10:15:30Z",
      "updatedAt": "2025-07-02T08:12:00Z",
      "contact": {
        "email": "contato@fsj.com.br",
        "phone": "+55 (11) 9****-1234"
      },
      "address": {
        "street": "Av. Brasil, 123",
        "city": "São Paulo",
        "state": "SP",
        "zip": "01234-000"
      }
    },
    {
      "id": "c7f8d2g3-4e3b-5b0f-0g7c-2b3c4d5e6f7g",
      "name": "Farmácia do Bairro",
      "rating": 4.5,
      "distance_km": 2.1,
      "image_url": "https://cdn.example.com/images/fdb.png",
      "taxId": "98.765.*** / 0001-45",
      "status": "active",
      "description": "Farmácia com entrega rápida",
      "createdAt": "2024-05-18T14:22:15Z",
      "updatedAt": "2025-06-28T10:05:00Z",
      "contact": {
        "email": "info@fdb.com.br",
        "phone": "+55 (11) 9****-5678"
      },
      "address": {
        "street": "Rua das Flores, 456",
        "city": "São Paulo",
        "state": "SP",
        "zip": "02345-000"
      }
    }
  ]
}
```

---

## 🔐 Permissões e Privacidade

### O que é sempre retornado
- ✅ Informações públicas (name, rating, status, createdAt)
- ✅ Dados genéricos (image_url, description)

### O que é mascarado/restrito
- 🔒 CPF/CNPJ: Mostrado parcialmente (ex: "12.345.*** / 0001-23")
- 🔒 Telefone: Mostrado parcialmente (ex: "+55 (11) 9****-1234")
- 🔒 Email: Completo (pois é usuário que controlou a visibilidade)
- 🔒 Endereço completo: Apenas se usuário autenticado + relacionamento solicitado

### Filtros aplicados por permissão
- Usuários anônimos: Apenas `status=active`
- Usuários autenticados: Sem restrições (vê seus próprios + públicos)
- Admins: Sem restrições

---

## ⚙️ Validações e Restrições

### Page e PageSize
```
- page mínima: 1 (se < 1, retornar página 1)
- pageSize padrão: 20
- pageSize máxima: 100 (se > 100, truncar para 100)
- Se pageSize não for inteiro: arredondar para inteiro
- Se não houver dados na página: retornar array vazio com meta correto
```

### SortBy
```
Campos válidos: name, rating, distance_km, createdAt, updatedAt, status
Se campo inválido: usar padrão "name"
```

### SortDir
```
Valores válidos: "asc", "desc" (case-insensitive)
Se inválido: usar "asc"
```

### Filtro por Q (busca textual)
```
- Case-insensitive
- Busca em: name, description, email, city
- Operador: "contém" (não exato)
- Exemplo: q="farm" → encontra "Farmácia", "Farm-2000", etc.
```

### Include (relacionamentos)
```
Valores válidos: "contact", "address", "metadata", "tags"
Valores inválidos: ignorados (sem erro)
Performance: cada relacionamento adicional aumenta ~10% tempo de resposta

Recomendação: 
- Sem include: 50ms
- Com 1 relacionamento: 55ms
- Com 2+ relacionamentos: 65ms+
```

---

## 📈 Performance e Paginação

### Recomendações

#### Paginação Offset-Based (Atual)
```
- Ideal para: < 10k registros
- Desvantagem: lento com offsets grandes
- Exemplo: page=1000, pageSize=20 (offset 20k)
- Uso: LAN Party Planner (volumes pequenos)
```

#### Paginação Cursor-Based (Alternativa futura)
```
- Ideal para: > 100k registros
- Desvantagem: precisa ordenação estável
- Exemplo: after=".../uuid123", limit=20
- Uso: Recomendado para escalabilidade
```

### Limites Recomendados
```
- Máximo de itens por requisição: 100 (pageSize)
- Máximo de páginas recomendadas: 1000
- Se page > totalPages: retornar array vazio
- Cache: resultados podem ser cacheados por 5 minutos
```

---

## 🔄 Tratamento de Erros

### Caso: pageSize inválido
```json
{
  "status": 200,
  "meta": { "pageSize": 20 },
  "message": "pageSize inválido, usando padrão 20"
}
```

### Caso: Filtro com zero resultados
```json
{
  "meta": {
    "total": 0,
    "page": 1,
    "pageSize": 20,
    "totalPages": 0,
    "hasNextPage": false,
    "hasPrevPage": false
  },
  "data": []
}
```

### Caso: Página além do máximo
```json
{
  "meta": {
    "total": 50,
    "page": 100,
    "pageSize": 20,
    "totalPages": 3,
    "hasNextPage": false,
    "hasPrevPage": true
  },
  "data": [],
  "warning": "Página solicitada (100) excede totalPages (3)"
}
```

---

## 🧪 Cenários de Teste

### Teste 1: Listagem Padrão
```
Input: GET /providers
Esperado: 20 itens, página 1, ordenados por name (asc)
Status: 200 OK
```

### Teste 2: Busca com Filtro
```
Input: GET /providers?filters.q=farm&filters.status=active
Esperado: Apenas ativos com "farm" no nome
Status: 200 OK
```

### Teste 3: Paginação
```
Input: GET /providers?page=2&pageSize=10
Esperado: Itens 11-20, meta com page=2, totalPages=ceil(total/10)
Status: 200 OK
```

### Teste 4: Ordenação
```
Input: GET /providers?sortBy=rating&sortDir=desc
Esperado: Ordenado por rating (maior primeiro)
Status: 200 OK
```

### Teste 5: Com Relacionamentos
```
Input: GET /providers?include=contact,address
Esperado: Inclui contact e address em cada item
Status: 200 OK
```

### Teste 6: Validações
```
Input: GET /providers?pageSize=500
Esperado: Truncado para pageSize=100, aviso no meta
Status: 200 OK

Input: GET /providers?sortBy=invalid_field
Esperado: Usa sortBy padrão (name), sem erro
Status: 200 OK
```

---

## 📚 Campos por Entidade

### Se aplicando a EVENTS
```json
{
  "id": "uuid",
  "name": "LAN Party 2024",
  "event_date": "2024-12-31",
  "status": "active",
  "description": "Maior evento do ano",
  "createdAt": "2024-03-12T10:15:30Z",
  "updatedAt": "2025-07-02T08:12:00Z"
}
```

### Se aplicando a GAMES
```json
{
  "id": "uuid",
  "title": "Counter-Strike 2",
  "genre": "FPS",
  "rating": 4.8,
  "total_matches": 1250,
  "min_players": 2,
  "max_players": 10,
  "status": "active",
  "cover_image_url": "https://...",
  "createdAt": "2024-03-12T10:15:30Z",
  "updatedAt": "2025-07-02T08:12:00Z"
}
```

### Se aplicando a PARTICIPANTS
```json
{
  "id": "uuid",
  "name": "João Silva",
  "email": "joao@example.com",
  "nickname": "JoaoGamer",
  "skill_level": 8,
  "avatar_url": "https://...",
  "isPremium": true,
  "status": "active",
  "rating": 4.6,
  "createdAt": "2024-03-12T10:15:30Z",
  "updatedAt": "2025-07-02T08:12:00Z"
}
```

### Se aplicando a TOURNAMENTS
```json
{
  "id": "uuid",
  "name": "Winter Championship 2024",
  "game_id": "uuid",
  "format": "Double Elimination",
  "status": "in_progress",
  "max_participants": 64,
  "prize_pool": 10000.0,
  "rating": 4.7,
  "start_date": "2024-12-15",
  "createdAt": "2024-03-12T10:15:30Z",
  "updatedAt": "2025-07-02T08:12:00Z"
}
```

### Se aplicando a VENUES
```json
{
  "id": "uuid",
  "name": "Arena Gaming SP",
  "city": "São Paulo",
  "state": "SP",
  "capacity": 500,
  "rating": 4.8,
  "price_per_hour": 250.0,
  "distance_km": 1.4,
  "is_verified": true,
  "image_url": "https://...",
  "status": "active",
  "createdAt": "2024-03-12T10:15:30Z",
  "updatedAt": "2025-07-02T08:12:00Z"
}
```

---

## 🎯 Critérios de Aceitação

- [x] Especificação clara de inputs/outputs
- [x] Exemplo JSON válido e mascarado
- [x] Restrições de performance documentadas
- [x] Validações e tratamento de erros definidos
- [x] Testes documentados
- [x] Campos parametrizáveis por entidade
- [x] Privacidade e permissões consideradas

---

**Status:** ✅ Especificação Completa  
**Versão:** 1.0  
**Data:** 2025-11-13

