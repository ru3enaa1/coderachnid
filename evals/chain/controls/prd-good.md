# PRD · RecallKit

Version 1 · 2026-10-22 · Status: DRAFT · Built from `docs/MARKET.md` (2026-10-20) and
`docs/OFFER.md` (2026-10-21).

## 1. What we are building

A web app where the receptionist of a small dental clinic uploads the patient list,
starts a recall campaign for patients overdue for their check-up, and sees who answered.
It also sends appointment confirmations. **It is not** a clinical record, a booking
system or a billing tool.

## 2. Who it is for and where it applies

- **First customer:** a clinic with one or two dentists and one receptionist.
- **Where it applies:** at the front desk, on the clinic's desktop computer, in a
  browser, connected; when the receptionist prepares the week's agenda, about once a
  week. Regions: Chile and Peru. Language: Spanish.
- **Not for:** chains with several sites, or clinics that want clinical records.

## 3. The problem

Patients never come back for their six-month check-up and the clinic notices months
later (market report, problem 2; 41 similar complaints in an owners' forum [S4]).
Today the receptionist calls by hand, about 6 hours a week, near USD 70 a month [S3].
Verdicts: the problem exists, VALIDATED; clinics pay monthly for recall alone, NOT YET
(tested by the offer's deposit page, threshold 8 deposits by 2026-11-07).

## 4. Goals, success metrics and non-goals

| Outcome | Metric | Start | Target | Measured |
|---|---|---|---|---|
| Overdue patients book again | patients booked per campaign | 0 (no campaigns today) | 10 in 60 days | campaign report, day 60 |
| The receptionist starts alone | minutes from sign-in to first campaign | unknown | 10 or less | timed with 5 clinics |

**Non-goals:** reducing no-shows below a set rate; replacing the clinic's agenda.

## 5. Core features

| Id | Feature | Problem it serves | Priority | How it works, in one line |
|---|---|---|---|---|
| F1 | Patient list import | problem 2 | Must | Upload a spreadsheet; the app keeps name, phone and last visit |
| F2 | Recall campaign | problem 2 | Must | Pick "overdue 6 months", review the list, send one message each |
| F3 | Replies and opt-out | problem 2 | Must | A reply marks the patient; "stop" removes them from every campaign |
| F4 | Appointment confirmation | problem 1 | Should | A message the day before; "yes" marks it confirmed |
| F5 | Multi-site | problem 4 | Later | — |

## 6. How it works

**First run (F1):**

| # | The user does | The system does | The user sees |
|---|---|---|---|
| 1 | Signs in and uploads the spreadsheet | Reads it, keeps three columns, counts rejected rows | "212 patients read, 4 rejected", with the reason for each |

**Recall campaign (F2, F3):**

| # | The user does | The system does | The user sees |
|---|---|---|---|
| 1 | Chooses "overdue 6 months" | Lists the patients, leaving out those who opted out | 40 patients, with the message preview |
| 2 | Presses "Send" | Sends one message per patient | "40 sent" |
| 3 | Opens the campaign later | Collects the replies | Who answered, who booked |

**When a step fails:** the messaging provider is down → nothing is marked as sent and
the screen says "Not sent: try again"; the spreadsheet has no phone column → the upload
is refused and the screen names the missing column.

## 7. User stories and acceptance criteria

- **US-1 (F2):** As a receptionist, I want to start a recall campaign for overdue
  patients, so that they book again.
  - AC-1.1: Given 40 patients whose last visit was over six months ago, when I start a
    campaign, then each receives one message and the campaign shows 40 sent.
  - AC-1.2: Given a patient who opted out, when the campaign runs, then that patient
    gets no message.
  - AC-1.3: Given the messaging provider is down, when I press "Send", then I see an
    error and nothing is marked as sent.
- **US-2 (F1):** As a receptionist, I want to upload my patient list, so that I don't
  type it again.
  - AC-2.1: Given a spreadsheet with 216 rows of which 4 have no phone, when I upload
    it, then 212 are read and 4 are listed as rejected with the reason.

## 8. Quality requirements

The campaign list of 500 patients opens in under 2 seconds on the clinic's computer ·
WCAG 2.2 AA · latest two versions of Chrome and Edge · Spanish.

## 9. Personal data and threats

| Data | Why | Where | Kept | Who sees it |
|---|---|---|---|---|
| Patient name and phone | to send messages | database, encrypted at rest | until opt-out plus 30 days | clinic staff |
| Last visit date | to find overdue patients | database | while the account exists | clinic staff |

| Threat | Control |
|---|---|
| One clinic reads another's patients | clinic id on every query, with a test |
| A leaked phone list | encryption at rest; export only for the owner role |
| Messages sent in the clinic's name by someone else | verified sender number |

## 10. Entities

Clinic (id, name, country) · Patient (id, clinic_id, name, phone, last_visit, opted_out)
· Campaign (id, clinic_id, kind, created_at) · Message (id, campaign_id, patient_id,
status, sent_at). Each record belongs to one clinic.

## 11. Frozen MVP scope

**In:** F1, F2, F3. **Explicitly not in:** clinical records, online booking,
integrations with agenda software, multi-site (F5). **Later:** F4.

## 12. Assumptions, risks and open questions

- ASSUMPTION: patients answer messages from a clinic number. Test: reply rate in the
  first five clinics.
- Risk: the messaging provider changes its prices. Action: the price per message is a
  setting, reviewed monthly.
- Open: which messaging provider in Peru? The owner, by 2026-11-01.

## 13. Traceability

| Problem | Feature | Stories | Verified by |
|---|---|---|---|
| 2 · patients never come back | F1 | US-2 | AC-2.1 |
| 2 · patients never come back | F2, F3 | US-1 | AC-1.1, AC-1.2, AC-1.3 |

## 14. Change log

- 2026-10-22 · first version · the owner.
