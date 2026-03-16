# CLAUDE.md — The Animist Apothecary

This file provides context for Claude when working on this codebase.

> **IMPORTANT: Push changes immediately!**
> This is a GitHub Pages site — changes only go live after `git push`.
> Always push as soon as changes are ready.

> **IMPORTANT: Supabase CLI is broken on this macOS version.**
> (`dyld: Symbol not found: _SecTrustCopyCertificateChain`)
> Save SQL as migration files for manual execution in the Supabase SQL Editor.
> Do NOT try to run `supabase db push` directly.

## Project Overview

**The Animist Apothecary** is a somatic & ceremonial practice management system. It manages clients, services/offerings, appointments, intake forms, mentorship containers, payments, and a full Command Center for the practitioner.

**Tech Stack:**
- Frontend: Static HTML/CSS/JS (no build step)
- Backend: Supabase (PostgreSQL + Storage + Auth + Edge Functions)
- Hosting: GitHub Pages with custom domain `theanimistapothecary.com`
- Auth: Supabase Auth (email/password + Google OAuth)

**Live URLs:**
- Public site: https://theanimistapothecary.com
- Admin Command Center: https://theanimistapothecary.com/admin/
- Client Portal: https://theanimistapothecary.com/portal/
- CRM: https://theanimistapothecary.com/crm/
- Auth callback: https://theanimistapothecary.com/auth/callback.html

## Deployment

Push to main and it's live. No build step, no PR process.
```bash
git add -A && git commit -m "message" && git push
```

## Supabase Details

- **Project ID:** `wdecjlrfulsdklqeetqb` (us-west-2)
- **Dashboard:** https://supabase.com/dashboard/project/wdecjlrfulsdklqeetqb
- **URL:** `https://wdecjlrfulsdklqeetqb.supabase.co`
- **Anon key:** in `shared/supabase.js`
- **Edge function base URL:** `https://wdecjlrfulsdklqeetqb.supabase.co/functions/v1/`

### Edge Function Deployment

```bash
supabase functions deploy gemini
supabase functions deploy send-email
supabase functions deploy sync-calendar
supabase functions deploy calendar-webhook --no-verify-jwt
supabase functions deploy import-calendar
supabase secrets set KEY=value
supabase functions logs <function-name>
```

## Shared Files

- `shared/supabase.js` — Supabase URL + anon key globals + STORAGE buckets (media, photos, documents)
- `shared/auth.js` — Auth: profile button, Google OAuth, email/password modal, `requireAuth()` guard
- `shared/admin.css` — Admin styles: stat cards, tables, modals, badges (themeable via `--aap-*` CSS vars)
- `shared/admin-sidebar.css` — Admin sidebar: 248px fixed, wine bg (#3D0C17), gold active accents
- `shared/ai-service.js` — AI: `ai(prompt, opts)` + `aiHelpers.*` → calls `gemini` edge function
- `shared/calendar-service.js` — Calendar: `calendarService.sync/remove(apptId)` → calls `sync-calendar`
- `shared/email-service.js` — Email: `sendEmail(opts)` + `emailTemplates.*` → calls `send-email`

### Auth System (`shared/auth.js`)

- **Google OAuth**: `window.signInWithGoogle()` — redirects to `auth/callback.html`
- **Login modal**: Email/password fallback + Google button
- **Avatar**: Shows photo (from Google) or initials
- **Page guard**: `requireAuth(callback)` — hides body until auth confirmed, redirects to `../index.html` if not authenticated
- **Supabase client**: Exposed as `window.adminSupabase`

**Script loading order (ALL admin pages):**
```html
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js"></script>
<script src="../shared/supabase.js"></script>
<script src="../shared/auth.js"></script>
```

### Admin Pages (`admin/`)

- All admin pages: `<meta name="robots" content="noindex, nofollow">`, load `shared/admin.css` + `shared/admin-sidebar.css`
- Auth guard pattern:
```javascript
requireAuth(function(user, supabase) {
    // authenticated — load data
});
```
- CRUD pattern: `admin-table` for listing, `admin-modal` for add/edit forms
- Always use `showToast()` not `alert()`
- Filter archived: `.filter(s => !s.is_archived)` client-side

### Admin Sidebar

- 248px fixed, background `#3D0C17` (wine), gold active border (`--aap-gold: #D4A843`)
- All 21 pages + analytics.html + strategy.html have the full sidebar nav
- Sidebar includes CRM link: `<a href="../crm/">🔮 CRM Overview</a>`

## External Services

### Email (Resend) ✅
- Secret: `RESEND_API_KEY` in Supabase
- Edge function: `send-email`
- Client module: `shared/email-service.js`

### AI (Google Gemini) ✅
- Secret: `GEMINI_API_KEY` in Supabase
- Model: `gemini-2.0-flash`
- Edge function: `gemini`
- Client module: `shared/ai-service.js`
- Free tier: 1,500 req/day, 15 RPM

### Google Calendar ✅
- Secrets: `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, `GOOGLE_CALENDAR_REFRESH_TOKEN`, `GOOGLE_CALENDAR_ID`
- Edge functions: `sync-calendar` (JWT required), `calendar-webhook` (no-verify-jwt), `import-calendar`
- Client module: `shared/calendar-service.js`
- **⚠️ Push channel expires ~March 17, 2026** — see `docs/INTEGRATIONS.md` for renewal instructions

### E-Signatures (SignWell)
- Config in `signwell_config` table
- Edge function: `signwell-webhook` (deploy with `--no-verify-jwt`)

## Conventions

1. `showToast()` not `alert()` in all admin pages
2. Filter archived items: `.filter(s => !s.is_archived)` client-side
3. Don't expose personal info in public/portal views
4. `openLightbox(url)` for images
5. Client-side image compression for files > 500KB
