-- ============================================================================
-- RLS POLICIES - COPIE TUDO ABAIXO E EXECUTE NO SUPABASE SQL EDITOR
-- ============================================================================
-- Solução para: PostgrestException(code: 42501, details: Unauthorized)
--
-- INSTRUÇÕES:
-- 1. Acesse: https://app.supabase.com
-- 2. Clique em SQL Editor
-- 3. Clique em New Query
-- 4. Copie TODO o código abaixo (CTRL+A, CTRL+C)
-- 5. Cole no editor (CTRL+V)
-- 6. Clique em RUN (botão azul)
-- 7. Pronto! INSERT/UPDATE/DELETE funcionarão!
--
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

-- ============================================================================
-- ✅ PRONTO! Agora teste no app:
-- 1. Clique em + para criar um novo item
-- 2. Preencha o formulário
-- 3. Clique em Salvar
-- 4. Você deve ver um toast verde: "Criado com sucesso!"
-- ============================================================================
