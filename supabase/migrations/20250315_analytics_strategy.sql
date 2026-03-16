-- ============================================================
--  The Animist Apothecary — Analytics & Strategy Migration
--  Run in Supabase SQL Editor
-- ============================================================

-- Strategic Planning: Concept Map Nodes
CREATE TABLE IF NOT EXISTS strategic_nodes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  title TEXT NOT NULL,
  description TEXT,
  node_type TEXT DEFAULT 'idea',
  category TEXT,
  status TEXT DEFAULT 'seed',
  priority TEXT DEFAULT 'medium',
  timeframe TEXT,
  target_date DATE,
  progress INTEGER DEFAULT 0,
  color TEXT,
  pos_x REAL DEFAULT 0,
  pos_y REAL DEFAULT 0,
  tags TEXT[],
  notes TEXT,
  linked_table TEXT,
  linked_id UUID,
  is_archived BOOLEAN DEFAULT FALSE
);
ALTER TABLE strategic_nodes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "auth_strategic_nodes" ON strategic_nodes FOR ALL USING (auth.role() = 'authenticated');

-- Strategic Planning: Connections Between Nodes
CREATE TABLE IF NOT EXISTS strategic_connections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT now(),
  source_node_id UUID REFERENCES strategic_nodes(id) ON DELETE CASCADE,
  target_node_id UUID REFERENCES strategic_nodes(id) ON DELETE CASCADE,
  relationship_type TEXT DEFAULT 'relates_to',
  label TEXT,
  strength INTEGER DEFAULT 5,
  notes TEXT,
  UNIQUE(source_node_id, target_node_id)
);
ALTER TABLE strategic_connections ENABLE ROW LEVEL SECURITY;
CREATE POLICY "auth_strategic_connections" ON strategic_connections FOR ALL USING (auth.role() = 'authenticated');

-- Practice Goals
CREATE TABLE IF NOT EXISTS practice_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  title TEXT NOT NULL,
  description TEXT,
  category TEXT,
  metric_type TEXT,
  target_value REAL,
  current_value REAL DEFAULT 0,
  timeframe TEXT NOT NULL,
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  status TEXT DEFAULT 'active',
  strategic_node_id UUID REFERENCES strategic_nodes(id),
  notes TEXT,
  is_archived BOOLEAN DEFAULT FALSE
);
ALTER TABLE practice_goals ENABLE ROW LEVEL SECURITY;
CREATE POLICY "auth_practice_goals" ON practice_goals FOR ALL USING (auth.role() = 'authenticated');

-- Practice Reflections
CREATE TABLE IF NOT EXISTS practice_reflections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  title TEXT,
  body TEXT,
  reflection_type TEXT NOT NULL,
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  wins TEXT,
  challenges TEXT,
  insights TEXT,
  intentions TEXT,
  gratitudes TEXT,
  tags TEXT[],
  mood TEXT,
  is_archived BOOLEAN DEFAULT FALSE
);
ALTER TABLE practice_reflections ENABLE ROW LEVEL SECURITY;
CREATE POLICY "auth_reflections" ON practice_reflections FOR ALL USING (auth.role() = 'authenticated');
