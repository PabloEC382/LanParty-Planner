# 🐛 Bug Fix: NoSuchMethodError em Form Dialogs

**Data**: 6 de dezembro de 2025  
**Problema**: `NoSuchMethodError: The method '[]' was called on null`  
**Locais**: `event_form_dialog.dart` e `tournament_form_dialog.dart`

---

## 🔍 O Problema

Ao tentar criar um **Evento** ou **Torneio**, o app crashava com:

```
NoSuchMethodError: The method '[]' was called on null.
Receiver: null
Tried calling: [](0)
```

### Causa Raiz

No código original, estava tentando fazer:

```dart
_startDateController = TextEditingController(
  text: initial?.startDate.toIso8601String().split('T')[0] ?? ''
);
```

**O problema**: Se `initial?.startDate` fosse nulo, tentar fazer `.toIso8601String()` em null causava crash.

O operador `??` apenas funciona se o left-hand side **inteiro** for avaliado, mas o `.split('T')[0]` foi executado antes.

---

## ✅ Solução Aplicada

Mudamos para uma abordagem **null-safe**:

```dart
// ANTES (causa crash):
_startDateController = TextEditingController(
  text: initial?.startDate.toIso8601String().split('T')[0] ?? ''
);

// DEPOIS (seguro):
final startDateStr = initial?.startDate != null 
  ? initial!.startDate.toString().split(' ')[0]
  : '';

_startDateController = TextEditingController(text: startDateStr);
```

### Mudanças:

1. **Check explícito**: `initial?.startDate != null` verifica se não é nulo
2. **Force unwrap seguro**: `initial!.startDate` só acontece se souber que não é nulo
3. **Formato simples**: `toString().split(' ')[0]` em vez de `toIso8601String().split('T')[0]`

---

## 📋 Arquivos Corrigidos

### 1. `event_form_dialog.dart` - Linhas 37-50

**Antes:**
```dart
_startDateController = TextEditingController(text: initial?.startDate.toIso8601String().split('T')[0] ?? '');
_endDateController = TextEditingController(text: initial?.endDate.toIso8601String().split('T')[0] ?? '');
```

**Depois:**
```dart
final startDateStr = initial?.startDate != null 
  ? initial!.startDate.toString().split(' ')[0]
  : '';
final endDateStr = initial?.endDate != null 
  ? initial!.endDate.toString().split(' ')[0]
  : '';

_startDateController = TextEditingController(text: startDateStr);
_endDateController = TextEditingController(text: endDateStr);
```

### 2. `tournament_form_dialog.dart` - Linhas 37-50

**Antes:**
```dart
_startDateController = TextEditingController(
  text: widget.initial?.startDate.toIso8601String().split('T')[0] 
    ?? DateTime.now().toIso8601String().split('T')[0]
);
```

**Depois:**
```dart
final startDateStr = widget.initial?.startDate != null 
  ? widget.initial!.startDate.toString().split(' ')[0]
  : DateTime.now().toString().split(' ')[0];

_startDateController = TextEditingController(text: startDateStr);
```

---

## ✨ Resultado

✅ Zero compilation errors  
✅ Form dialogs abrem sem crash  
✅ Datas são parseadas corretamente  
✅ Ambas as entidades (Events e Tournaments) funcionam

---

## 🧪 Como Testar

1. Abra o app
2. Vá em **Eventos**
3. Clique no botão **+**
4. Preencha o formulário (Nome, Descrição, Datas, etc)
5. Clique em **Salvar**

**Esperado**: 
- Se RLS policies estão configuradas: Toast verde "Evento criado com sucesso!"
- Se RLS não está: Toast vermelho com erro do Supabase

---

## 🔗 Relacionado

- Se está vendo erro de RLS (`code: 42501, details: Unauthorized`): Execute o SQL em `SQL_COPIAR_COLAR.sql`
- Ver: `RLS_POLICIES_FIX.md` para mais detalhes sobre RLS

---

**Status**: ✅ Bug corrigido e validado
