# Database Schema — The Animist Apothecary

All tables live in Supabase (PostgreSQL). Row Level Security is enabled on all tables. All admin-facing tables use the policy `auth.role() = 'authenticated'`.

Migration file: `supabase/migrations/20250315_command_center.sql`

---

## Core Tables (Pre-existing)

### `clients`
| Column | Type | Notes |
|--------|------|-------|
| id | UUID PK | |
| created_at | TIMESTAMPTZ | |
| full_name | TEXT | |
| email | TEXT | |
| phone | TEXT | |
| notes | TEXT | |
| is_archived | BOOLEAN | default false |
| pipeline_stage | TEXT | inquiry\|intake\|active\|aftercare\|integration\|community\|alumni |
| source | TEXT | How they found the practice |
| referral_source | TEXT | Who referred them |
| location | TEXT | |
| timezone | TEXT | |
| birth_date | DATE | |
| portal_user_id | UUID | Links to auth.users |

### `appointments`
| Column | Type | Notes |
|--------|------|-------|
| id | UUID PK | |
| created_at | TIMESTAMPTZ | |
| client_id | UUID FK → clients | |
| service_id | UUID FK → services | optional |
| start_time | TIMESTAMPTZ | |
| duration_minutes | INTEGER | |
| status | TEXT | scheduled\|confirmed\|completed\|cancelled\|no_show |
| notes | TEXT | |
| location | TEXT | |

### `services`
| Column | Type | Notes |
|--------|------|-------|
| id | UUID PK | |
| name | TEXT | |
| description | TEXT | |
| service_type | TEXT | session\|arc\|immersion\|ceremony\|group\|divination\|other |
| duration_minutes | INTEGER | |
| price_cents | INTEGER | |
| is_active | BOOLEAN | |

### `mentorship_containers`
| Column | Type | Notes |
|--------|------|-------|
| id | UUID PK | |
| created_at | TIMESTAMPTZ | |
| client_id | UUID FK → clients | |
| title | TEXT | |
| description | TEXT | |
| stage | TEXT | Current phase |
| start_date | DATE | |
| end_date | DATE | |
| status | TEXT | active\|completed\|on_hold\|cancelled |
| notes | TEXT | |

### `payments`
| Column | Type | Notes |
|--------|------|-------|
| id | UUID PK | |
| created_at | TIMESTAMPTZ | |
| client_id | UUID FK → clients | |
| amount_cents | INTEGER | |
| payment_method | TEXT | card\|check\|cash\|venmo\|zelle\|wire\|other |
| status | TEXT | completed\|pending\|refunded\|failed |
| payment_date | DATE | |
| notes | TEXT | |
| appointment_id | UUID FK → appointments | optional |

### `intake_submissions` (or `form_submissions`)
Stores form data from public book.html submissions.

---

## Command Center Tables (Added 2025-03-15)

### `session_notes`
| Column | Type | Notes |
|--------|------|-------|
| id | UUID PK | |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |
| appointment_id | UUID FK → appointments | optional |
| client_id | UUID FK → clients | |
| practitioner_notes | TEXT | Admin only |
| client_visible_notes | TEXT | Shown in client portal |
| integration_tasks | TEXT | |
| session_themes | TEXT[] | Array of theme tags |
| follow_up_date | DATE | |
| is_archived | BOOLEAN | |

### `integration_plans`
| Column | Type | Notes |
|--------|------|-------|
| id | UUID PK | |
| client_id | UUID FK → clients | |
| mentorship_container_id | UUID FK → mentorship_containers | optional |
| title | TEXT | |
| description | TEXT | |
| practices | JSONB | Array: [{name, frequency, notes}] |
| resources | JSONB | Array: [{title, url, notes}] |
| start_date | DATE | |
| end_date | DATE | |
| status | TEXT | active\|completed\|paused |
| is_archived | BOOLEAN | |

### `invoices`
| Column | Type | Notes |
|--------|------|-------|
| id | UUID PK | |
| client_id | UUID FK → clients | |
| invoice_number | TEXT | e.g. INV-20250315-001 |
| line_items | JSONB | Array: [{description, amount_cents}] |
| subtotal_cents | INTEGER | |
| tax_cents | INTEGER | |
| total_cents | INTEGER | |
| currency | TEXT | default USD |
| status | TEXT | draft\|sent\|paid\|overdue\|cancelled |
| due_date | DATE | |
| paid_at | TIMESTAMPTZ | |
| notes | TEXT | |

### `travel_itinerary`
| Column | Type | Notes |
|--------|------|-------|
| id | UUID PK | |
| title | TEXT | |
| destination | TEXT | |
| start_date | DATE | |
| end_date | DATE | |
| purpose | TEXT | client_work\|speaking\|retreat\|training\|personal\|scouting |
| details | JSONB | {flights, lodging, transport} |
| linked_engagement_id | UUID | FK → speaking_engagements |
| notes | TEXT | |
| status | TEXT | planned\|confirmed\|in_progress\|completed\|cancelled |

### `collaborators`
| Column | Type | Notes |
|--------|------|-------|
| id | UUID PK | |
| full_name | TEXT | |
| email | TEXT | |
| phone | TEXT | |
| role | TEXT | co-facilitator\|mentor\|advisor\|practitioner\|musician\|chef\|other |
| organization | TEXT | |
| location | TEXT | |
| bio | TEXT | |
| specialties | TEXT[] | |
| tags | TEXT[] | |
| relationship_notes | TEXT | |
| last_contact | DATE | |

### `speaking_engagements`
| Column | Type | Notes |
|--------|------|-------|
| id | UUID PK | |
| title | TEXT | |
| event_name | TEXT | |
| venue_id | UUID FK → venues | |
| host_contact | TEXT | |
| host_email | TEXT | |
| event_date | DATE | |
| event_end_date | DATE | |
| topic | TEXT | |
| audience_type | TEXT | |
| expected_attendance | INTEGER | |
| compensation_type | TEXT | paid\|honorarium\|trade\|volunteer\|promotion |
| compensation_amount_cents | INTEGER | |
| travel_covered | BOOLEAN | |
| status | TEXT | inquiry\|confirmed\|preparing\|completed\|cancelled |
| notes | TEXT | |

### `venues`
| Column | Type | Notes |
|--------|------|-------|
| id | UUID PK | |
| name | TEXT | |
| venue_type | TEXT | retreat_center\|studio\|conference\|outdoor\|private_home\|virtual\|other |
| address | TEXT | |
| city | TEXT | |
| state | TEXT | |
| country | TEXT | default US |
| capacity | INTEGER | |
| contact_name | TEXT | |
| contact_email | TEXT | |
| contact_phone | TEXT | |
| website | TEXT | |
| rate_info | TEXT | |
| notes | TEXT | |
| rating | INTEGER | 1–5 |
| tags | TEXT[] | |

### `contacts_vip`
| Column | Type | Notes |
|--------|------|-------|
| id | UUID PK | |
| full_name | TEXT | |
| email | TEXT | |
| phone | TEXT | |
| title | TEXT | |
| organization | TEXT | |
| category | TEXT | potential_mentor\|industry_leader\|media\|funder\|ally\|elder\|other |
| location | TEXT | |
| connection_context | TEXT | |
| relationship_status | TEXT | identified\|introduced\|in_dialogue\|collaborating\|dormant |
| last_contact | DATE | |
| next_action | TEXT | |
| notes | TEXT | |
| tags | TEXT[] | |

### `referral_network`
| Column | Type | Notes |
|--------|------|-------|
| id | UUID PK | |
| full_name | TEXT | |
| email | TEXT | |
| phone | TEXT | |
| practice_type | TEXT | therapist\|doctor\|bodyworker\|acupuncturist\|naturopath\|psychiatrist\|coach\|other |
| specialty | TEXT | |
| organization | TEXT | |
| location | TEXT | |
| referral_direction | TEXT | inbound\|outbound\|both |
| clients_referred | INTEGER | |
| relationship_notes | TEXT | |
| last_contact | DATE | |

### `regional_hubs`
| Column | Type | Notes |
|--------|------|-------|
| id | UUID PK | |
| name | TEXT | |
| region | TEXT | |
| city | TEXT | |
| state | TEXT | |
| country | TEXT | |
| description | TEXT | |
| hub_type | TEXT | community_circle\|training_site\|retreat_center\|affiliate\|satellite |
| primary_contact | TEXT | |
| contact_email | TEXT | |
| member_count | INTEGER | |
| active_offerings | INTEGER | |
| venue_id | UUID FK → venues | |
| status | TEXT | seeding\|growing\|established\|dormant |
| notes | TEXT | |

### `email_log`
| Column | Type | Notes |
|--------|------|-------|
| id | UUID PK | |
| created_at | TIMESTAMPTZ | |
| recipient_email | TEXT | |
| recipient_name | TEXT | |
| subject | TEXT | |
| template | TEXT | |
| status | TEXT | sent\|failed\|bounced |
| client_id | UUID FK → clients | optional |
| context | TEXT | Message body |

### `client_portal_accounts`
| Column | Type | Notes |
|--------|------|-------|
| id | UUID PK | |
| client_id | UUID FK → clients | UNIQUE |
| auth_user_id | UUID | FK → auth.users |
| display_name | TEXT | |
| portal_preferences | JSONB | |
| last_login | TIMESTAMPTZ | |
| is_active | BOOLEAN | |

### `client_agreements`
| Column | Type | Notes |
|--------|------|-------|
| id | UUID PK | |
| client_id | UUID FK → clients | |
| title | TEXT | |
| document_type | TEXT | informed_consent\|intake_agreement\|payment_agreement\|confidentiality\|liability_waiver\|other |
| content | TEXT | Full document text |
| signed_at | TIMESTAMPTZ | |
| signature_id | TEXT | SignWell signature ID |
| status | TEXT | pending\|sent\|signed\|expired |

### `community_resources`
| Column | Type | Notes |
|--------|------|-------|
| id | UUID PK | |
| title | TEXT | |
| description | TEXT | |
| category | TEXT | reading\|practice\|community\|referral\|media\|tool |
| url | TEXT | |
| access_level | TEXT | public\|all_clients\|active_clients\|arc_clients |
| sort_order | INTEGER | Lower = first |
| is_active | BOOLEAN | |

### `client_journal`
| Column | Type | Notes |
|--------|------|-------|
| id | UUID PK | |
| client_id | UUID FK → clients | |
| title | TEXT | optional |
| body | TEXT | |
| mood | TEXT | peaceful\|tender\|unsettled\|electric\|grieving\|grateful\|curious\|tired\|alive |
| tags | TEXT[] | |
| is_private | BOOLEAN | default true |

---

## Row Level Security Summary

All tables: `FOR ALL USING (auth.role() = 'authenticated')` — admin access only from server-side.

Client portal access is mediated through `client_portal_accounts` and filters data server-side by `client_id`.
