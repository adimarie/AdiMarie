-- ============================================================
--  The Animist Apothecary — Command Center Migration
--  Run in Supabase SQL Editor or via: supabase db push
-- ============================================================

-- Expand clients table with pipeline tracking
ALTER TABLE clients ADD COLUMN IF NOT EXISTS pipeline_stage TEXT DEFAULT 'inquiry';
ALTER TABLE clients ADD COLUMN IF NOT EXISTS source TEXT;
ALTER TABLE clients ADD COLUMN IF NOT EXISTS referral_source TEXT;
ALTER TABLE clients ADD COLUMN IF NOT EXISTS location TEXT;
ALTER TABLE clients ADD COLUMN IF NOT EXISTS timezone TEXT;
ALTER TABLE clients ADD COLUMN IF NOT EXISTS birth_date DATE;
ALTER TABLE clients ADD COLUMN IF NOT EXISTS portal_user_id UUID;

-- Session Notes
CREATE TABLE IF NOT EXISTS session_notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  appointment_id UUID REFERENCES appointments(id),
  client_id UUID REFERENCES clients(id),
  practitioner_notes TEXT,
  client_visible_notes TEXT,
  integration_tasks TEXT,
  session_themes TEXT[],
  follow_up_date DATE,
  is_archived BOOLEAN DEFAULT FALSE
);
ALTER TABLE session_notes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "auth_session_notes" ON session_notes FOR ALL USING (auth.role() = 'authenticated');

-- Integration Plans (aftercare)
CREATE TABLE IF NOT EXISTS integration_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  client_id UUID REFERENCES clients(id),
  mentorship_container_id UUID REFERENCES mentorship_containers(id),
  title TEXT NOT NULL,
  description TEXT,
  practices JSONB DEFAULT '[]',
  resources JSONB DEFAULT '[]',
  start_date DATE,
  end_date DATE,
  status TEXT DEFAULT 'active',
  is_archived BOOLEAN DEFAULT FALSE
);
ALTER TABLE integration_plans ENABLE ROW LEVEL SECURITY;
CREATE POLICY "auth_integration_plans" ON integration_plans FOR ALL USING (auth.role() = 'authenticated');

-- Invoices
CREATE TABLE IF NOT EXISTS invoices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  client_id UUID REFERENCES clients(id),
  invoice_number TEXT NOT NULL,
  line_items JSONB DEFAULT '[]',
  subtotal_cents INTEGER DEFAULT 0,
  tax_cents INTEGER DEFAULT 0,
  total_cents INTEGER DEFAULT 0,
  currency TEXT DEFAULT 'USD',
  status TEXT DEFAULT 'draft',
  due_date DATE,
  paid_at TIMESTAMPTZ,
  notes TEXT,
  is_archived BOOLEAN DEFAULT FALSE
);
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
CREATE POLICY "auth_invoices" ON invoices FOR ALL USING (auth.role() = 'authenticated');

-- Travel Itinerary
CREATE TABLE IF NOT EXISTS travel_itinerary (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  title TEXT NOT NULL,
  destination TEXT,
  start_date DATE NOT NULL,
  end_date DATE,
  purpose TEXT,
  details JSONB DEFAULT '{}',
  linked_engagement_id UUID,
  notes TEXT,
  status TEXT DEFAULT 'planned',
  is_archived BOOLEAN DEFAULT FALSE
);
ALTER TABLE travel_itinerary ENABLE ROW LEVEL SECURITY;
CREATE POLICY "auth_travel" ON travel_itinerary FOR ALL USING (auth.role() = 'authenticated');

-- Collaborators
CREATE TABLE IF NOT EXISTS collaborators (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  full_name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  role TEXT,
  organization TEXT,
  location TEXT,
  bio TEXT,
  specialties TEXT[],
  tags TEXT[],
  relationship_notes TEXT,
  last_contact DATE,
  is_archived BOOLEAN DEFAULT FALSE
);
ALTER TABLE collaborators ENABLE ROW LEVEL SECURITY;
CREATE POLICY "auth_collaborators" ON collaborators FOR ALL USING (auth.role() = 'authenticated');

-- Speaking Engagements
CREATE TABLE IF NOT EXISTS speaking_engagements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  title TEXT NOT NULL,
  event_name TEXT,
  venue_id UUID,
  host_contact TEXT,
  host_email TEXT,
  event_date DATE,
  event_end_date DATE,
  topic TEXT,
  audience_type TEXT,
  expected_attendance INTEGER,
  compensation_type TEXT,
  compensation_amount_cents INTEGER,
  travel_covered BOOLEAN DEFAULT FALSE,
  status TEXT DEFAULT 'inquiry',
  notes TEXT,
  is_archived BOOLEAN DEFAULT FALSE
);
ALTER TABLE speaking_engagements ENABLE ROW LEVEL SECURITY;
CREATE POLICY "auth_speaking" ON speaking_engagements FOR ALL USING (auth.role() = 'authenticated');

-- Venues
CREATE TABLE IF NOT EXISTS venues (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  name TEXT NOT NULL,
  venue_type TEXT,
  address TEXT,
  city TEXT,
  state TEXT,
  country TEXT DEFAULT 'US',
  capacity INTEGER,
  contact_name TEXT,
  contact_email TEXT,
  contact_phone TEXT,
  website TEXT,
  rate_info TEXT,
  notes TEXT,
  rating INTEGER,
  tags TEXT[],
  is_archived BOOLEAN DEFAULT FALSE
);
ALTER TABLE venues ENABLE ROW LEVEL SECURITY;
CREATE POLICY "auth_venues" ON venues FOR ALL USING (auth.role() = 'authenticated');

ALTER TABLE speaking_engagements ADD CONSTRAINT fk_speaking_venue FOREIGN KEY (venue_id) REFERENCES venues(id);

-- People of Import (VIP Contacts)
CREATE TABLE IF NOT EXISTS contacts_vip (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  full_name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  title TEXT,
  organization TEXT,
  category TEXT,
  location TEXT,
  connection_context TEXT,
  relationship_status TEXT DEFAULT 'identified',
  last_contact DATE,
  next_action TEXT,
  notes TEXT,
  tags TEXT[],
  is_archived BOOLEAN DEFAULT FALSE
);
ALTER TABLE contacts_vip ENABLE ROW LEVEL SECURITY;
CREATE POLICY "auth_vip" ON contacts_vip FOR ALL USING (auth.role() = 'authenticated');

-- Referral Network
CREATE TABLE IF NOT EXISTS referral_network (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  full_name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  practice_type TEXT,
  specialty TEXT,
  organization TEXT,
  location TEXT,
  referral_direction TEXT DEFAULT 'both',
  clients_referred INTEGER DEFAULT 0,
  relationship_notes TEXT,
  last_contact DATE,
  is_archived BOOLEAN DEFAULT FALSE
);
ALTER TABLE referral_network ENABLE ROW LEVEL SECURITY;
CREATE POLICY "auth_referrals" ON referral_network FOR ALL USING (auth.role() = 'authenticated');

-- Regional Hubs
CREATE TABLE IF NOT EXISTS regional_hubs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  name TEXT NOT NULL,
  region TEXT NOT NULL,
  city TEXT,
  state TEXT,
  country TEXT DEFAULT 'US',
  description TEXT,
  hub_type TEXT,
  primary_contact TEXT,
  contact_email TEXT,
  member_count INTEGER DEFAULT 0,
  active_offerings INTEGER DEFAULT 0,
  venue_id UUID REFERENCES venues(id),
  status TEXT DEFAULT 'seeding',
  notes TEXT,
  is_archived BOOLEAN DEFAULT FALSE
);
ALTER TABLE regional_hubs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "auth_hubs" ON regional_hubs FOR ALL USING (auth.role() = 'authenticated');

-- Email Log
CREATE TABLE IF NOT EXISTS email_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT now(),
  recipient_email TEXT NOT NULL,
  recipient_name TEXT,
  subject TEXT NOT NULL,
  template TEXT,
  status TEXT DEFAULT 'sent',
  client_id UUID REFERENCES clients(id),
  context TEXT,
  is_archived BOOLEAN DEFAULT FALSE
);
ALTER TABLE email_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY "auth_emails" ON email_log FOR ALL USING (auth.role() = 'authenticated');

-- Client Portal Accounts
CREATE TABLE IF NOT EXISTS client_portal_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  client_id UUID REFERENCES clients(id) UNIQUE,
  auth_user_id UUID,
  display_name TEXT,
  portal_preferences JSONB DEFAULT '{}',
  last_login TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT TRUE
);
ALTER TABLE client_portal_accounts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "auth_portal" ON client_portal_accounts FOR ALL USING (auth.role() = 'authenticated');

-- Client Agreements
CREATE TABLE IF NOT EXISTS client_agreements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  client_id UUID REFERENCES clients(id),
  title TEXT NOT NULL,
  document_type TEXT,
  content TEXT,
  signed_at TIMESTAMPTZ,
  signature_id TEXT,
  status TEXT DEFAULT 'pending',
  is_archived BOOLEAN DEFAULT FALSE
);
ALTER TABLE client_agreements ENABLE ROW LEVEL SECURITY;
CREATE POLICY "auth_agreements" ON client_agreements FOR ALL USING (auth.role() = 'authenticated');

-- Community Resources
CREATE TABLE IF NOT EXISTS community_resources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  title TEXT NOT NULL,
  description TEXT,
  category TEXT,
  url TEXT,
  access_level TEXT DEFAULT 'all_clients',
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  is_archived BOOLEAN DEFAULT FALSE
);
ALTER TABLE community_resources ENABLE ROW LEVEL SECURITY;
CREATE POLICY "auth_resources" ON community_resources FOR ALL USING (auth.role() = 'authenticated');

-- Client Journal
CREATE TABLE IF NOT EXISTS client_journal (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  client_id UUID REFERENCES clients(id),
  title TEXT,
  body TEXT,
  mood TEXT,
  tags TEXT[],
  is_private BOOLEAN DEFAULT TRUE,
  is_archived BOOLEAN DEFAULT FALSE
);
ALTER TABLE client_journal ENABLE ROW LEVEL SECURITY;
CREATE POLICY "auth_journal" ON client_journal FOR ALL USING (auth.role() = 'authenticated');
