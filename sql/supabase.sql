-- ============================================================================
-- LAN PARTY PLANNER - Database Schema
-- ============================================================================
-- Este arquivo SQL cria todas as tabelas necessárias para o LAN Party Planner.
-- Execute este script no Editor SQL do Supabase.
--
-- Tabelas criadas:
-- 1. venues - Locais onde eventos são realizados
-- 2. events - Eventos do aplicativo
-- 3. games - Jogos disponíveis
-- 4. participants - Participantes registrados
-- 5. tournaments - Torneios disponíveis
--
-- ⚠️ IMPORTANTE: Execute todas as statements neste arquivo!
-- ============================================================================

-- ============================================================================
-- 1. VENUES TABLE
-- ============================================================================
-- Armazena informações sobre os locais/venues onde eventos ocorrem.
--
CREATE TABLE IF NOT EXISTS venues (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  address TEXT NOT NULL,
  city TEXT NOT NULL,
  state TEXT NOT NULL,
  capacity INTEGER NOT NULL,
  facilities TEXT[], -- Array de strings com as facilidades
  rating DOUBLE PRECISION NOT NULL DEFAULT 0.0,
  total_reviews INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_venues_city ON venues(city);
CREATE INDEX IF NOT EXISTS idx_venues_state ON venues(state);
CREATE INDEX IF NOT EXISTS idx_venues_updated_at ON venues(updated_at DESC);

-- Comentários descritivos
COMMENT ON TABLE venues IS 'Armazena informações sobre locais/venues';
COMMENT ON COLUMN venues.id IS 'Identificador único (UUID ou string)';
COMMENT ON COLUMN venues.name IS 'Nome do venue';
COMMENT ON COLUMN venues.capacity IS 'Capacidade máxima de pessoas';
COMMENT ON COLUMN venues.facilities IS 'Array com facilidades disponíveis (ex: WiFi, Parking, etc)';
COMMENT ON COLUMN venues.rating IS 'Avaliação média (0-5)';
COMMENT ON COLUMN venues.total_reviews IS 'Número total de avaliações';

-- ============================================================================
-- 2. EVENTS TABLE
-- ============================================================================
-- Armazena informações sobre eventos.
--
CREATE TABLE IF NOT EXISTS events (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  start_date TEXT NOT NULL, -- Formato ISO8601 (YYYY-MM-DD)
  end_date TEXT NOT NULL,   -- Formato ISO8601 (YYYY-MM-DD)
  description TEXT NOT NULL,
  start_time TEXT NOT NULL, -- Formato HH:mm (ex: 18:30)
  end_time TEXT NOT NULL,   -- Formato HH:mm (ex: 23:59)
  venue_id TEXT REFERENCES venues(id) ON DELETE SET NULL,
  state TEXT, -- Estado do evento (ex: draft, published, ongoing, finished)
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_events_venue_id ON events(venue_id);
CREATE INDEX IF NOT EXISTS idx_events_state ON events(state);
CREATE INDEX IF NOT EXISTS idx_events_start_date ON events(start_date);
CREATE INDEX IF NOT EXISTS idx_events_updated_at ON events(updated_at DESC);

-- Comentários descritivos
COMMENT ON TABLE events IS 'Armazena informações sobre eventos';
COMMENT ON COLUMN events.id IS 'Identificador único (UUID ou string)';
COMMENT ON COLUMN events.name IS 'Nome do evento';
COMMENT ON COLUMN events.start_date IS 'Data de início (YYYY-MM-DD)';
COMMENT ON COLUMN events.end_date IS 'Data de término (YYYY-MM-DD)';
COMMENT ON COLUMN events.start_time IS 'Hora de início (HH:mm)';
COMMENT ON COLUMN events.end_time IS 'Hora de término (HH:mm)';
COMMENT ON COLUMN events.venue_id IS 'Referência ao venue (local)';
COMMENT ON COLUMN events.state IS 'Estado do evento (draft, published, ongoing, finished)';

-- ============================================================================
-- 3. GAMES TABLE
-- ============================================================================
-- Armazena informações sobre jogos disponíveis.
--
CREATE TABLE IF NOT EXISTS games (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  cover_image_url TEXT,
  genre TEXT NOT NULL,
  min_players INTEGER NOT NULL,
  max_players INTEGER NOT NULL,
  platforms TEXT[], -- Array de strings com plataformas (ex: PC, Console, Mobile)
  average_rating DOUBLE PRECISION NOT NULL DEFAULT 0.0,
  total_matches INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_games_genre ON games(genre);
CREATE INDEX IF NOT EXISTS idx_games_average_rating ON games(average_rating DESC);
CREATE INDEX IF NOT EXISTS idx_games_updated_at ON games(updated_at DESC);

-- Comentários descritivos
COMMENT ON TABLE games IS 'Armazena informações sobre jogos';
COMMENT ON COLUMN games.id IS 'Identificador único (UUID ou string)';
COMMENT ON COLUMN games.title IS 'Nome do jogo';
COMMENT ON COLUMN games.genre IS 'Gênero do jogo (ex: FPS, RPG, Strategy)';
COMMENT ON COLUMN games.min_players IS 'Número mínimo de jogadores';
COMMENT ON COLUMN games.max_players IS 'Número máximo de jogadores';
COMMENT ON COLUMN games.platforms IS 'Array com plataformas suportadas (PC, PS5, Xbox, etc)';
COMMENT ON COLUMN games.average_rating IS 'Avaliação média (0-5)';
COMMENT ON COLUMN games.total_matches IS 'Número total de partidas registradas';

-- ============================================================================
-- 4. PARTICIPANTS TABLE
-- ============================================================================
-- Armazena informações sobre participantes/jogadores.
--
CREATE TABLE IF NOT EXISTS participants (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  avatar_url TEXT,
  nickname TEXT NOT NULL UNIQUE,
  skill_level INTEGER NOT NULL, -- Nível de habilidade (ex: 1-10)
  preferred_games TEXT[], -- Array com IDs dos jogos preferidos
  is_premium BOOLEAN NOT NULL DEFAULT FALSE,
  registered_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_participants_email ON participants(email);
CREATE INDEX IF NOT EXISTS idx_participants_nickname ON participants(nickname);
CREATE INDEX IF NOT EXISTS idx_participants_skill_level ON participants(skill_level);
CREATE INDEX IF NOT EXISTS idx_participants_is_premium ON participants(is_premium);
CREATE INDEX IF NOT EXISTS idx_participants_updated_at ON participants(updated_at DESC);

-- Comentários descritivos
COMMENT ON TABLE participants IS 'Armazena informações sobre participantes/jogadores';
COMMENT ON COLUMN participants.id IS 'Identificador único (UUID ou string)';
COMMENT ON COLUMN participants.name IS 'Nome completo do participante';
COMMENT ON COLUMN participants.email IS 'Email único do participante';
COMMENT ON COLUMN participants.nickname IS 'Nome de usuário único no sistema';
COMMENT ON COLUMN participants.skill_level IS 'Nível de habilidade (1-10, onde 10 é expert)';
COMMENT ON COLUMN participants.preferred_games IS 'Array com IDs dos jogos preferidos';
COMMENT ON COLUMN participants.is_premium IS 'Indica se é usuário premium';

-- ============================================================================
-- 5. TOURNAMENTS TABLE
-- ============================================================================
-- Armazena informações sobre torneios.
--
CREATE TABLE IF NOT EXISTS tournaments (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  game_id TEXT NOT NULL REFERENCES games(id) ON DELETE RESTRICT,
  format TEXT NOT NULL, -- Formato do torneio (ex: single_elimination, round_robin, swiss)
  status TEXT NOT NULL, -- Status do torneio (ex: draft, registration_open, ongoing, finished)
  max_participants INTEGER NOT NULL,
  current_participants INTEGER NOT NULL DEFAULT 0,
  prize_pool DOUBLE PRECISION NOT NULL DEFAULT 0.0,
  start_date TEXT NOT NULL, -- Formato ISO8601 (YYYY-MM-DD)
  end_date TEXT,            -- Formato ISO8601 (YYYY-MM-DD)
  organizer_ids TEXT[], -- Array com IDs dos organizadores
  rules JSONB, -- Regras customizadas em formato JSON
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_tournaments_game_id ON tournaments(game_id);
CREATE INDEX IF NOT EXISTS idx_tournaments_status ON tournaments(status);
CREATE INDEX IF NOT EXISTS idx_tournaments_format ON tournaments(format);
CREATE INDEX IF NOT EXISTS idx_tournaments_start_date ON tournaments(start_date);
CREATE INDEX IF NOT EXISTS idx_tournaments_updated_at ON tournaments(updated_at DESC);

-- Comentários descritivos
COMMENT ON TABLE tournaments IS 'Armazena informações sobre torneios';
COMMENT ON COLUMN tournaments.id IS 'Identificador único (UUID ou string)';
COMMENT ON COLUMN tournaments.name IS 'Nome do torneio';
COMMENT ON COLUMN tournaments.game_id IS 'ID do jogo associado ao torneio';
COMMENT ON COLUMN tournaments.format IS 'Formato do torneio (single_elimination, round_robin, swiss, etc)';
COMMENT ON COLUMN tournaments.status IS 'Status do torneio (draft, registration_open, ongoing, finished)';
COMMENT ON COLUMN tournaments.max_participants IS 'Número máximo de participantes';
COMMENT ON COLUMN tournaments.current_participants IS 'Número atual de participantes inscritos';
COMMENT ON COLUMN tournaments.prize_pool IS 'Prêmio total em dinheiro';
COMMENT ON COLUMN tournaments.organizer_ids IS 'Array com IDs dos organizadores/admins';
COMMENT ON COLUMN tournaments.rules IS 'Regras customizadas em formato JSON';

-- ============================================================================
-- POLÍTICAS DE SEGURANÇA (RLS - Row Level Security)
-- ============================================================================
-- ✅ IMPORTANTE: RLS está HABILITADO no Supabase!
-- As políticas abaixo permitem:
-- - SELECT: Qualquer usuário pode LER dados (público)
-- - INSERT: Qualquer usuário autenticado pode CRIAR
-- - UPDATE: Qualquer usuário autenticado pode EDITAR
-- - DELETE: Qualquer usuário autenticado pode DELETAR
--
-- Isso é adequado para um MVP. Para produção com auth real, ajuste conforme necessário.
--

-- ============================================================================
-- VENUES POLICIES
-- ============================================================================
ALTER TABLE venues ENABLE ROW LEVEL SECURITY;

-- Policy: Qualquer um pode ler
CREATE POLICY "venues_select_public" ON venues
  FOR SELECT USING (true);

-- Policy: Usuários autenticados podem criar
CREATE POLICY "venues_insert_authenticated" ON venues
  FOR INSERT WITH CHECK (true);

-- Policy: Usuários autenticados podem editar
CREATE POLICY "venues_update_authenticated" ON venues
  FOR UPDATE USING (true) WITH CHECK (true);

-- Policy: Usuários autenticados podem deletar
CREATE POLICY "venues_delete_authenticated" ON venues
  FOR DELETE USING (true);

-- ============================================================================
-- EVENTS POLICIES
-- ============================================================================
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

-- Policy: Qualquer um pode ler
CREATE POLICY "events_select_public" ON events
  FOR SELECT USING (true);

-- Policy: Usuários autenticados podem criar
CREATE POLICY "events_insert_authenticated" ON events
  FOR INSERT WITH CHECK (true);

-- Policy: Usuários autenticados podem editar
CREATE POLICY "events_update_authenticated" ON events
  FOR UPDATE USING (true) WITH CHECK (true);

-- Policy: Usuários autenticados podem deletar
CREATE POLICY "events_delete_authenticated" ON events
  FOR DELETE USING (true);

-- ============================================================================
-- GAMES POLICIES
-- ============================================================================
ALTER TABLE games ENABLE ROW LEVEL SECURITY;

-- Policy: Qualquer um pode ler
CREATE POLICY "games_select_public" ON games
  FOR SELECT USING (true);

-- Policy: Usuários autenticados podem criar
CREATE POLICY "games_insert_authenticated" ON games
  FOR INSERT WITH CHECK (true);

-- Policy: Usuários autenticados podem editar
CREATE POLICY "games_update_authenticated" ON games
  FOR UPDATE USING (true) WITH CHECK (true);

-- Policy: Usuários autenticados podem deletar
CREATE POLICY "games_delete_authenticated" ON games
  FOR DELETE USING (true);

-- ============================================================================
-- PARTICIPANTS POLICIES
-- ============================================================================
ALTER TABLE participants ENABLE ROW LEVEL SECURITY;

-- Policy: Qualquer um pode ler
CREATE POLICY "participants_select_public" ON participants
  FOR SELECT USING (true);

-- Policy: Usuários autenticados podem criar
CREATE POLICY "participants_insert_authenticated" ON participants
  FOR INSERT WITH CHECK (true);

-- Policy: Usuários autenticados podem editar
CREATE POLICY "participants_update_authenticated" ON participants
  FOR UPDATE USING (true) WITH CHECK (true);

-- Policy: Usuários autenticados podem deletar
CREATE POLICY "participants_delete_authenticated" ON participants
  FOR DELETE USING (true);

-- ============================================================================
-- TOURNAMENTS POLICIES
-- ============================================================================
ALTER TABLE tournaments ENABLE ROW LEVEL SECURITY;

-- Policy: Qualquer um pode ler
CREATE POLICY "tournaments_select_public" ON tournaments
  FOR SELECT USING (true);

-- Policy: Usuários autenticados podem criar
CREATE POLICY "tournaments_insert_authenticated" ON tournaments
  FOR INSERT WITH CHECK (true);

-- Policy: Usuários autenticados podem editar
CREATE POLICY "tournaments_update_authenticated" ON tournaments
  FOR UPDATE USING (true) WITH CHECK (true);

-- Policy: Usuários autenticados podem deletar
CREATE POLICY "tournaments_delete_authenticated" ON tournaments
  FOR DELETE USING (true);

-- ============================================================================
-- DADOS DE EXEMPLO (OPCIONAL)
-- ============================================================================
-- Descomente as linhas abaixo para inserir dados de exemplo.
--
-- INSERT INTO venues (id, name, address, city, state, capacity, facilities, rating, total_reviews)
-- VALUES (
--   'venue_001',
--   'TechHub Arena',
--   'Rua das Inovações, 123',
--   'São Paulo',
--   'SP',
--   500,
--   ARRAY['WiFi', 'Parking', 'Cafeteria', 'RestRooms'],
--   4.5,
--   120
-- );
--
-- INSERT INTO games (id, title, description, genre, min_players, max_players, platforms, average_rating, total_matches)
-- VALUES (
--   'game_001',
--   'Counter-Strike 2',
--   'Tactical first-person shooter',
--   'FPS',
--   2,
--   128,
--   ARRAY['PC', 'Steam'],
--   4.8,
--   5420
-- );
--
-- INSERT INTO participants (id, name, email, nickname, skill_level, is_premium, registered_at)
-- VALUES (
--   'participant_001',
--   'João Silva',
--   'joao.silva@email.com',
--   'ProPlayer',
--   9,
--   TRUE,
--   CURRENT_TIMESTAMP
-- );

-- ============================================================================
-- FIM DO SCRIPT
-- ============================================================================
-- ✅ Todas as tabelas foram criadas com sucesso!
-- 
-- Próximos passos:
-- 1. Execute este script no SQL Editor do Supabase
-- 2. Verifique se as tabelas foram criadas em Database > Tables
-- 3. Configure RLS (Row Level Security) se necessário
-- 4. Configure Webhooks para sincronização em tempo real (opcional)
-- 5. Teste a conexão do app com as tabelas
--
-- ============================================================================
