-- ============================================================
-- Migration: clients, intake_forms, session_notes
-- Created:   2026-03-22
-- Run in:    Supabase SQL Editor
-- ============================================================

-- ── clients ─────────────────────────────────────────────────
create table if not exists public.clients (
  id               uuid primary key default gen_random_uuid(),
  full_name        text not null,
  email            text not null,
  phone            text,
  pronouns         text,
  birth_date       date,
  location         text,
  timezone         text,
  source           text,
  referral_source  text,
  emergency_contact text,
  pipeline_stage   text not null default 'intake',
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

comment on table  public.clients                  is 'Client records created from the public intake form and admin console.';
comment on column public.clients.pipeline_stage   is 'intake | inquiry | active | completed | archived';
comment on column public.clients.source           is 'referral | social_media | web_search | event | community | returning | other';

-- Unique email (soft constraint — comment out if you want multiple records per email)
create unique index if not exists clients_email_idx on public.clients (lower(email));

-- Fast lookups by pipeline stage
create index if not exists clients_pipeline_idx on public.clients (pipeline_stage);

-- ── intake_forms ─────────────────────────────────────────────
create table if not exists public.intake_forms (
  id           uuid primary key default gen_random_uuid(),
  client_id    uuid not null references public.clients (id) on delete cascade,
  form_type    text not null default 'initial_intake',
  responses    jsonb not null default '{}'::jsonb,
  submitted_at timestamptz not null default now(),
  created_at   timestamptz not null default now()
);

comment on table  public.intake_forms           is 'Intake form submissions linked to a client record.';
comment on column public.intake_forms.responses is 'JSONB blob with keys: consent, safety, body, mind, spirit.';

create index if not exists intake_forms_client_idx      on public.intake_forms (client_id);
create index if not exists intake_forms_submitted_idx   on public.intake_forms (submitted_at desc);

-- ── session_notes ────────────────────────────────────────────
create table if not exists public.session_notes (
  id                   uuid primary key default gen_random_uuid(),
  client_id            uuid not null references public.clients (id) on delete cascade,
  practitioner_notes   text,
  client_visible_notes text,
  session_themes       text,          -- comma-separated tags
  integration_tasks    text,
  follow_up_date       date,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);

comment on table  public.session_notes                  is 'Practitioner session notes — private and client-visible — linked to a client.';
comment on column public.session_notes.session_themes   is 'Comma-separated theme tags, e.g. "grief, boundaries, ancestral healing".';

create index if not exists session_notes_client_idx     on public.session_notes (client_id);
create index if not exists session_notes_created_idx    on public.session_notes (created_at desc);
create index if not exists session_notes_followup_idx   on public.session_notes (follow_up_date) where follow_up_date is not null;

-- ── updated_at trigger ───────────────────────────────────────
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger clients_updated_at
  before update on public.clients
  for each row execute function public.set_updated_at();

create trigger session_notes_updated_at
  before update on public.session_notes
  for each row execute function public.set_updated_at();

-- ── Row Level Security ───────────────────────────────────────
-- Public intake form (anonymous insert only — no read-back)
alter table public.clients       enable row level security;
alter table public.intake_forms  enable row level security;
alter table public.session_notes enable row level security;

-- Anon: insert only (intake form submission)
create policy "anon can insert clients"
  on public.clients for insert
  to anon
  with check (true);

create policy "anon can insert intake_forms"
  on public.intake_forms for insert
  to anon
  with check (true);

-- Authenticated (admin console): full access
create policy "auth full access to clients"
  on public.clients for all
  to authenticated
  using (true)
  with check (true);

create policy "auth full access to intake_forms"
  on public.intake_forms for all
  to authenticated
  using (true)
  with check (true);

create policy "auth full access to session_notes"
  on public.session_notes for all
  to authenticated
  using (true)
  with check (true);
