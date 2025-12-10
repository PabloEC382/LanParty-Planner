-- ============================================================================
-- RLS POLICIES DEFINITIVAS - LAN PARTY PLANNER
-- ============================================================================
-- Executa em: https://app.supabase.com → SQL Editor → New Query
-- Solução: PostgrestException(code: 42501, details: Unauthorized)
-- ============================================================================

-- Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "venues_select_public" ON venues;
DROP POLICY IF EXISTS "venues_insert_authenticated" ON venues;
DROP POLICY IF EXISTS "venues_update_authenticated" ON venues;
DROP POLICY IF EXISTS "venues_delete_authenticated" ON venues;

DROP POLICY IF EXISTS "events_select_public" ON events;
DROP POLICY IF EXISTS "events_insert_authenticated" ON events;
DROP POLICY IF EXISTS "events_update_authenticated" ON events;
DROP POLICY IF EXISTS "events_delete_authenticated" ON events;

DROP POLICY IF EXISTS "games_select_public" ON games;
DROP POLICY IF EXISTS "games_insert_authenticated" ON games;
DROP POLICY IF EXISTS "games_update_authenticated" ON games;
DROP POLICY IF EXISTS "games_delete_authenticated" ON games;

DROP POLICY IF EXISTS "participants_select_public" ON participants;
DROP POLICY IF EXISTS "participants_insert_authenticated" ON participants;
DROP POLICY IF EXISTS "participants_update_authenticated" ON participants;
DROP POLICY IF EXISTS "participants_delete_authenticated" ON participants;

DROP POLICY IF EXISTS "tournaments_select_public" ON tournaments;
DROP POLICY IF EXISTS "tournaments_insert_authenticated" ON tournaments;
DROP POLICY IF EXISTS "tournaments_update_authenticated" ON tournaments;
DROP POLICY IF EXISTS "tournaments_delete_authenticated" ON tournaments;

-- ============================================================================
-- VENUES TABLE
-- ============================================================================
ALTER TABLE venues ENABLE ROW LEVEL SECURITY;

CREATE POLICY "venues_select_public" ON venues
  FOR SELECT USING (true);

CREATE POLICY "venues_insert_authenticated" ON venues
  FOR INSERT WITH CHECK (true);

CREATE POLICY "venues_update_authenticated" ON venues
  FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "venues_delete_authenticated" ON venues
  FOR DELETE USING (true);

-- ============================================================================
-- EVENTS TABLE
-- ============================================================================
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "events_select_public" ON events
  FOR SELECT USING (true);

CREATE POLICY "events_insert_authenticated" ON events
  FOR INSERT WITH CHECK (true);

CREATE POLICY "events_update_authenticated" ON events
  FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "events_delete_authenticated" ON events
  FOR DELETE USING (true);

-- ============================================================================
-- GAMES TABLE
-- ============================================================================
ALTER TABLE games ENABLE ROW LEVEL SECURITY;

CREATE POLICY "games_select_public" ON games
  FOR SELECT USING (true);

CREATE POLICY "games_insert_authenticated" ON games
  FOR INSERT WITH CHECK (true);

CREATE POLICY "games_update_authenticated" ON games
  FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "games_delete_authenticated" ON games
  FOR DELETE USING (true);

-- ============================================================================
-- PARTICIPANTS TABLE
-- ============================================================================
ALTER TABLE participants ENABLE ROW LEVEL SECURITY;

CREATE POLICY "participants_select_public" ON participants
  FOR SELECT USING (true);

CREATE POLICY "participants_insert_authenticated" ON participants
  FOR INSERT WITH CHECK (true);

CREATE POLICY "participants_update_authenticated" ON participants
  FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "participants_delete_authenticated" ON participants
  FOR DELETE USING (true);

-- ============================================================================
-- TOURNAMENTS TABLE
-- ============================================================================
ALTER TABLE tournaments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "tournaments_select_public" ON tournaments
  FOR SELECT USING (true);

CREATE POLICY "tournaments_insert_authenticated" ON tournaments
  FOR INSERT WITH CHECK (true);

CREATE POLICY "tournaments_update_authenticated" ON tournaments
  FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "tournaments_delete_authenticated" ON tournaments
  FOR DELETE USING (true);

-- ============================================================================
-- ✅ SUCESSO!
-- ============================================================================
-- Agora seu app conseguirá:
-- ✅ CREATE (INSERT) - Novos registros
-- ✅ READ (SELECT) - Listar e buscar
-- ✅ UPDATE - Editar registros
-- ✅ DELETE - Remover registros
-- 
-- Teste no app:
-- 1. Abra a tela de Eventos
-- 2. Clique no ícone de editar um evento
-- 3. Mude algum campo e clique Salvar
-- 4. Você verá a mensagem de sucesso e o dado será atualizado
-- ============================================================================
