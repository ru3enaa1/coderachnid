# Product brief · RecallKit · 2026-10-22

## Part A · Design direction

### What the competitors look like
Competitors A, B and D use clinical blue and white, stock photos of smiling dentists and
dense feature grids; C and E use plain SaaS dashboards. Category default: blue-white
clinic template. Free visual position: a warm, editorial look no competitor uses.

### Branding skeleton (proposal: the owner has no logo or type yet)
- Family: Hero Object, because a single tangible object (a soft rendered appointment
  card) reads as calm and stands apart from the stock-photo default.
- Type: a serif with italic accents for display (72/56 px), a grotesk for text (17 px),
  monospace labels (11 px uppercase).
- Palette: #F4EFE6 background, #1E1C1A ink, #8A8378 muted, one accent #D9643A (terracotta).
  Body text contrast 15.8:1.
- Hero visual: a soft clay appointment card floating over a warm haze, headline across
  its lower edge.
- Signature detail: a small rotating badge "next recall in 6 months".

### Layout
Desktop: hero (headline "Patients come back", one dark pill CTA "Start a recall"),
three numbered steps 01/02/03, pricing (three tiers), FAQ, footer. Mobile: same order,
one column, CTA sticky at the bottom. States: empty campaign list ("No campaigns yet:
start your first recall"), loading skeletons, send error with retry, success toast.

### Mockup prompt
```
Landing page for RecallKit, desktop 1440 px and mobile 390 px. 12-column grid, 96 px
margins. Background #F4EFE6, ink #1E1C1A, one accent #D9643A. Hero: a soft clay
appointment card floating over a warm haze; headline "Patients come back" in a serif,
72 px, italic on "back", crossing the card's lower edge; one dark pill button "Start a
recall". Below: steps 01/02/03 with monospace labels, hairline rules; pricing with three
tiers (Reminders USD 19, Recall USD 39 highlighted, Clinic USD 59); a rotating circular
badge "next recall in 6 months"; faint film grain. Testimonials row as a grey
PLACEHOLDER box.
```

### Guardrails
- Social proof (testimonials, clinic counts, logos) is a marked PLACEHOLDER until real.
- Text over the hero passes WCAG 2.2 AA; the hero image stays under 200 KB with a still
  fallback; motion respects reduced-motion.
- Generated art is original; references are not reused.

## Part B · System requirements

### Stories
1. As a receptionist, I want to start a recall campaign for patients overdue for a
   check-up, so that they book again (problem 2).
   - Given 40 patients whose last visit was over six months ago, when I start a
     campaign, then each receives one message and the campaign shows 40 sent.
   - Given a patient who opted out, when the campaign runs, then that patient gets no
     message.
   - Given the messaging provider is down, when I start a campaign, then I see an error
     and nothing is marked as sent.
2. As an owner, I want appointment confirmations, so that no-shows drop (problem 1).
   - Given an appointment tomorrow, when the patient replies "yes", then it is marked
     confirmed; when there is no reply in 12 hours, then the clinic is alerted.

### Personal data and threats
| Data | Why | Where | Kept | Who sees |
|---|---|---|---|---|
| patient name, phone | send messages | database, encrypted at rest | until opt-out + 30 days | clinic staff |
| last visit date | find overdue patients | database | as long as the clinic account | clinic staff |
Threats: one clinic reading another's patients (control: tenant id on every query and a
test for it); message spoofing (control: verified sender number); phone list leak
(control: encryption at rest, no export without owner role).

### Entities
Clinic (id, name, country) · Patient (id, clinic_id, name, phone, last_visit, opted_out)
· Campaign (id, clinic_id, kind, created_at) · Message (id, campaign_id, patient_id,
status, sent_at). Prices shown to users carry their source (sourced data).

### Frozen MVP scope
In: recall campaigns, confirmations, opt-out, three tiers billing.
Not in: clinical records, online booking, integrations, multi-site.

### Open questions
- Which messaging provider in Peru? Owner, by 2026-11-01.
