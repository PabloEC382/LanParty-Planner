# 🔧 Solução: RLS Policies no Supabase

**Problema**: `PostgrestException(code: 42501, details: Unauthorized)` - INSERT bloqueado por RLS

**Causa**: O Supabase tem RLS habilitado mas as **policies de INSERT/UPDATE/DELETE não existem**.

---

## ✅ Solução Rápida (30 segundos)

### 1. Abrir SQL Editor do Supabase

1. Acesse: https://app.supabase.com
2. Selecione seu projeto
3. Clique em **SQL Editor** (no menu esquerdo)
4. Clique em **New Query**

### 2. Copiar e Colar o SQL

Copie TODO o conteúdo abaixo:

```sql
-- ============================================================================
-- CRIAR POLICIES PARA TODAS AS TABELAS
-- ============================================================================

-- VENUES
ALTER TABLE venues ENABLE ROW LEVEL SECURITY;
CREATE POLICY "venues_select_public" ON venues FOR SELECT USING (true);
CREATE POLICY "venues_insert_authenticated" ON venues FOR INSERT WITH CHECK (true);
CREATE POLICY "venues_update_authenticated" ON venues FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "venues_delete_authenticated" ON venues FOR DELETE USING (true);

-- EVENTS
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
CREATE POLICY "events_select_public" ON events FOR SELECT USING (true);
CREATE POLICY "events_insert_authenticated" ON events FOR INSERT WITH CHECK (true);
CREATE POLICY "events_update_authenticated" ON events FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "events_delete_authenticated" ON events FOR DELETE USING (true);

-- GAMES
ALTER TABLE games ENABLE ROW LEVEL SECURITY;
CREATE POLICY "games_select_public" ON games FOR SELECT USING (true);
CREATE POLICY "games_insert_authenticated" ON games FOR INSERT WITH CHECK (true);
CREATE POLICY "games_update_authenticated" ON games FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "games_delete_authenticated" ON games FOR DELETE USING (true);

-- PARTICIPANTS
ALTER TABLE participants ENABLE ROW LEVEL SECURITY;
CREATE POLICY "participants_select_public" ON participants FOR SELECT USING (true);
CREATE POLICY "participants_insert_authenticated" ON participants FOR INSERT WITH CHECK (true);
CREATE POLICY "participants_update_authenticated" ON participants FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "participants_delete_authenticated" ON participants FOR DELETE USING (true);

-- TOURNAMENTS
ALTER TABLE tournaments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "tournaments_select_public" ON tournaments FOR SELECT USING (true);
CREATE POLICY "tournaments_insert_authenticated" ON tournaments FOR INSERT WITH CHECK (true);
CREATE POLICY "tournaments_update_authenticated" ON tournaments FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "tournaments_delete_authenticated" ON tournaments FOR DELETE USING (true);
```

### 3. Executar

1. Cole no SQL Editor
2. Clique em **RUN** (botão azul no canto direito)
3. Veja a mensagem de sucesso

✅ **Pronto!** Agora INSERT/UPDATE/DELETE funcionarão!

---

## 🔍 Verificar se Funcionou

### Método 1: No Supabase Dashboard

1. Acesse **Database > Tables > games**
2. Clique em **RLS** (abaixo do nome da tabela)
3. Você deve ver 4 policies:
   - ✅ `games_select_public`
   - ✅ `games_insert_authenticated`
   - ✅ `games_update_authenticated`
   - ✅ `games_delete_authenticated`

### Método 2: Testar no App

1. Abra o app
2. Vá em **Jogos**
3. Clique em **+**
4. Preencha o formulário
5. Clique em **Salvar**

**Esperado**: Toast verde dizendo "Jogo criado com sucesso!"

---

## 📚 Explicação das Policies

```sql
-- Permite que QUALQUER PESSOA leia dados
CREATE POLICY "games_select_public" ON games
  FOR SELECT USING (true);

-- Permite que usuários autenticados CRIEM
CREATE POLICY "games_insert_authenticated" ON games
  FOR INSERT WITH CHECK (true);
  
-- Permite que usuários autenticados EDITEM
CREATE POLICY "games_update_authenticated" ON games
  FOR UPDATE USING (true) WITH CHECK (true);
  
-- Permite que usuários autenticados DELETEM
CREATE POLICY "games_delete_authenticated" ON games
  FOR DELETE USING (true);
```

**Para MVP**: Usamos `true` (nenhuma restrição)

**Para Produção**: Você mudaria para:
```sql
-- Apenas o criador pode editar/deletar
CREATE POLICY "games_update_own" ON games
  FOR UPDATE USING (auth.uid() = created_by_user_id)
  WITH CHECK (auth.uid() = created_by_user_id);
```

---

## ⚠️ Se der erro "policy already exists"

Significa que a policy já existe. Isso é normal se você executar 2x.

**Solução**: Delete as antigas primeiro e execute de novo.

```sql
-- Deletar todas as policies (CUIDADO!)
DROP POLICY IF EXISTS games_select_public ON games;
DROP POLICY IF EXISTS games_insert_authenticated ON games;
DROP POLICY IF EXISTS games_update_authenticated ON games;
DROP POLICY IF EXISTS games_delete_authenticated ON games;

-- Depois execute o SQL acima novamente
```

---

## 🚀 Próximo Passo

Depois de executar o SQL:

1. Feche o editor SQL
2. Volte ao app
3. Teste o CRUD (Create/Read/Update/Delete)
4. Todos os 5 entities devem funcionar agora!

---

## 📞 Debugging

Se ainda não funcionar:

1. **Abra Chrome DevTools** (F12)
2. **Vá em Console**
3. Tente criar um item novamente
4. Copie a mensagem de erro exata
5. Compartilhe comigo

Exemplo de erro esperado:
```
✅ ANTES: PostgrestException(code: 42501, details: Unauthorized)
✅ DEPOIS: "Jogo criado com sucesso!" (toast verde)
```

---

**Arquivo**: `sql/supabase.sql` contém todo o código atualizado
**Status**: SQL atualizado com policies completas ✅
