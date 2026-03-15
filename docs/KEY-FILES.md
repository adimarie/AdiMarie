# Key Files — The Animist Apothecary

## Public Site (`/`)

| File | Purpose |
|------|---------|
| `index.html` | Homepage — hero, story, offerings, testimonial, CTA |
| `about.html` | About Adi Marie — bio, writing, workshops, appearances |
| `book.html` | Inquiry/booking form — client intake entry point |
| `community.html` | Community hubs, events, newsletter |
| `mythopoetic.html` | Cornerstone offering — Mythopoetic Living Arcs |
| `shamanic-bodywork.html` | Offering detail — Shamanic Bodywork |
| `personal-immersions.html` | Offering detail — Personal Immersions |
| `ceremonial-groups.html` | Offering detail — Ceremonial Groups |
| `platicas.html` | Offering detail — Plát icas (Guidance & Counsel) |
| `divinations.html` | Offering detail — Ancestral & Elemental Divinations |
| `css/styles.css` | Public site design system (all CSS custom properties, components) |
| `js/main.js` | Public site JS (scroll, accordion, fade-in, active nav, form handler) |

## Shared Infrastructure (`/shared/`)

| File | Purpose |
|------|---------|
| `shared/supabase.js` | Supabase client init — exports `SUPABASE_URL`, `SUPABASE_ANON_KEY`, initializes client |
| `shared/auth.js` | Auth module — profile button, login modal, `requireAuth()` guard, `window.adminSupabase` |
| `shared/admin.css` | Admin UI component styles — stat cards, tables, modals, badges, forms |
| `shared/admin-sidebar.css` | Admin sidebar layout — sidebar nav, wine bg, gold active accents, main content area |

## Admin Command Center (`/admin/`)

All pages are noindex, require `requireAuth()`, and use the shared sidebar layout.

### Dashboard
| File | Purpose |
|------|---------|
| `admin/index.html` | Dashboard — stat cards, section card grid for all modules |

### Client Dossier
| File | Purpose |
|------|---------|
| `admin/clients.html` | Client records — full list, pipeline stage filter, create/edit modal |
| `admin/pipeline.html` | Kanban board — clients grouped by pipeline stage (7 columns) |
| `admin/intake-forms.html` | Intake form submissions from book.html |
| `admin/session-notes.html` | Session notes — practitioner + client-visible notes, themes, follow-ups |
| `admin/integration.html` | Aftercare & integration plans — practices, resources, timelines |
| `admin/agreements.html` | Client agreements — informed consent, intake docs, liability waivers |

### Practice
| File | Purpose |
|------|---------|
| `admin/appointments.html` | Calendar & scheduling — all appointments, create/edit, status tracking |
| `admin/services.html` | Offerings configuration — name, type, duration, price, active status |
| `admin/mentorship.html` | Mentorship arcs — long-form developmental containers |
| `admin/payments.html` | Payment records — amounts, methods, dates, status |
| `admin/invoices.html` | Invoice management — line items, auto-numbering, status tracking |

### Communications
| File | Purpose |
|------|---------|
| `admin/emails.html` | Email center — log viewer + compose (logs to email_log, requires Resend for actual sending) |

### Network
| File | Purpose |
|------|---------|
| `admin/collaborators.html` | Collaborators — co-facilitators, mentors, advisors, allied practitioners |
| `admin/referrals.html` | Referral network — inbound/outbound referral partners |
| `admin/vip-contacts.html` | People of Import — strategic relationships, elders, media, funders |
| `admin/regional-hubs.html` | Regional hubs — community circles and satellite locations |

### Engagements
| File | Purpose |
|------|---------|
| `admin/speaking.html` | Speaking engagements — events, venues, compensation, status |
| `admin/venues.html` | Venue directory — retreat centers, studios, outdoor spaces |
| `admin/travel.html` | Travel itinerary — flights, lodging, purpose, linked engagements |

### Community
| File | Purpose |
|------|---------|
| `admin/community-resources.html` | Resource library — categorized resources for clients, access level control |

## Client Portal (`/portal/`)

All pages (except login.html) use the `initPortal()` auth guard which verifies `client_portal_accounts` record.

| File | Purpose |
|------|---------|
| `portal/login.html` | Client login — Google OAuth + email/password, redirects to index.html |
| `portal/index.html` | Client dashboard — welcome, journey stage, upcoming sessions, tasks, quick actions |
| `portal/sessions.html` | Session history — upcoming and past appointments with session notes |
| `portal/agreements.html` | Client documents — agreements, consent forms, signed status |
| `portal/onboarding.html` | Welcome & onboarding — checklist, journey stages explained, practitioner intro |
| `portal/resources.html` | Resource library — community_resources filtered by client access level |
| `portal/journal.html` | Reflection journal — private client journal entries (client_journal table) |
| `portal/profile.html` | Profile — client info, journey stage, sign out |
| `portal/portal.css` | Portal design system — sage/cream palette, sanctuary aesthetic |

## Database & Infrastructure

| File | Purpose |
|------|---------|
| `supabase/migrations/20250315_command_center.sql` | Command Center DB migration — all new tables + RLS policies |
| `docs/SCHEMA.md` | Full database schema reference |
| `docs/KEY-FILES.md` | This file |
| `CLAUDE.md` | AI assistant context — tech stack, deployment, auth patterns, conventions |

## Next.js App (`/src/`) — Coexisting

A Next.js 16 app lives in `src/` and coexists with the static site. GitHub Pages serves static files from root. The Next.js app is not built/deployed by the current CI workflow.

| File | Purpose |
|------|---------|
| `src/lib/supabase.ts` | Supabase client for Next.js app |
| `next.config.ts` | basePath must match GitHub repo name |
| `src/i18n/config.ts` | Supported locales |
