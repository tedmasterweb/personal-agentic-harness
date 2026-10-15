# 05 — RACI and Estimates

---

## 1. Roles

| Role | Who | Engagement |
|---|---|---|
| **Owner / Operator** | Ted | Full time-equivalent as available |
| **Data protection counsel** | External, Spanish, GDPR specialist | Project engagement, then retainer or ad hoc |
| **Gestor / accountant** | Existing | Company structure, tax, invoicing |
| **Insurance broker** | External | One-off placement, annual renewal |
| **DPO** | External fractional — **only if required**, see [02](02-gdpr-obligations.md) §7 | Retainer |
| **Penetration tester** | External | Once, before certification or first enterprise customer |
| **Certification body** | Accredited, UKAS/ENAC-equivalent | Phase 4 only |
| **Customer** | — | Controller: their own DPIA, lawful basis, data subject relations |

---

## 2. RACI matrix

**R** = Responsible (does it) · **A** = Accountable (owns outcome) · **C** = Consulted · **I** = Informed

| Workstream | Ted | Counsel | Gestor | Broker | DPO | Pentest | Cert body | Customer |
|---|---|---|---|---|---|---|---|---|
| **Phase 0 — Validate** |
| Genericise runbook | R/A | | | | | | | I |
| Build install automation | R/A | | | | | | | |
| Services agreement (Model A) | A | R | | | | | | C |
| Pilot customer delivery | R/A | | | | | | | C |
| **Phase 1 — Legal** |
| DPA drafting | A/C | R | | | C | | | C |
| ToS, privacy notice | A/C | R | | | | | | I |
| DPO requirement determination | A | R | | | | | | |
| Company structure review | A | C | R | | | | | |
| Insurance placement | A | | C | R | | | | I |
| **Phase 2 — Technical** |
| Secrets vault (C3) | R/A | | | | I | | | |
| Audit logging (C2) | R/A | | | | I | | | I |
| LUKS custody model (C1) | R/A | C | | | C | | | **C — they choose** |
| Break-glass procedure (C4) | R/A | C | | | C | | | I |
| Backups (C5) | R/A | | | | | | | C |
| Export/erasure tooling (C6) | R/A | C | | | C | | | I |
| Per-customer VM migration (C7) | R/A | | | | | | | I |
| Provisioning automation (C8, C9) | R/A | | | | | | | |
| **Phase 3 — ISMS** |
| ROPA | R/A | C | | | C | | | I |
| Template DPIA | R/A | C | | | C | | | **R — theirs to complete** |
| TOMs documentation | R/A | | | | C | | | I |
| Risk assessment & treatment | R/A | | | | C | | | |
| Incident response plan | R/A | C | | | C | | | I |
| Trust page | R/A | C | | | | | | I |
| **Phase 4 — Certification** |
| ISMS implementation | R/A | | | | C | | I | |
| Internal audit | R/A | | | | C | | | |
| Penetration test | A | | | | | R | I | I |
| Stage 1 / Stage 2 audit | A/C | | | | C | C | R | I |
| **Ongoing** |
| Sub-processor change notification | R/A | | | | I | | | I |
| Breach response | R/A | C | | C | C | | | **C/I — notify within 24h** |
| Data subject request assistance | R | C | | | C | | | A — controller owns response |
| Surveillance audits | A/C | | | | | | R | I |

**Note the single point of failure:** you are R or A on nearly everything. That is normal for a sole operator but it is itself a risk an auditor will raise — specifically around business continuity ("what happens if you're unavailable for a month?"). Have an answer before you're asked: a documented runbook (you have one), a named backup contact, and ideally an arrangement with another technical person for emergency cover.

---

## 3. Effort estimates — your time

Working days. Assumes your existing skill level and ISO background; a first-timer would take substantially longer on Phase 3.

| Phase | Workstream | Days |
|---|---|---|
| **0** | Genericise runbook | 3–5 |
| **0** | Install automation (Terraform + scripts + testing) | 10–15 |
| **0** | Pilot delivery (3 × ~1 day incl. iteration) | 3–5 |
| **0** | Sales/outreach to find pilots | 5–10 |
| | **Phase 0 subtotal** | **21–35** |
| **1** | Counsel engagement, briefing, review cycles | 4–6 |
| **1** | Insurance and structure admin | 2–3 |
| | **Phase 1 subtotal** | **6–9** |
| **2** | Secrets vault + migration | 4–8 |
| **2** | Audit logging | 5–10 |
| **2** | LUKS custody + break-glass implementation | 3–5 |
| **2** | Backups (design, implement, **test restore**) | 5–8 |
| **2** | Export/erasure tooling *(hardest item — agent memory)* | 6–12 |
| **2** | Per-customer VM provisioning + de-provisioning | 5–8 |
| **2** | Monitoring/alerting | 3–5 |
| | **Phase 2 subtotal** | **31–56** |
| **3** | ROPA | 2–4 |
| **3** | Template DPIA | 5–8 |
| **3** | TOMs, risk assessment, treatment plan | 5–8 |
| **3** | Incident response plan + tabletop test | 3–4 |
| **3** | Trust page, onboarding pack, templates | 4–6 |
| | **Phase 3 subtotal** | **19–30** |
| **4** | ISMS operation, internal audit, evidence, audit support | 25–40 |
| | **Phase 4 subtotal** | **25–40** |

**Totals:** Model A viable after Phase 0 (**21–35 days**). Model B ready after Phases 0–3 (**77–130 days**). Certified after Phase 4 (**102–170 days**).

At 3 days/week, Model B readiness is roughly **6–10 months** elapsed.

---

## 4. Cash cost estimates

All figures are **planning estimates for budgeting** — get quotes.

### One-off

| Item | Low | High | Notes |
|---|---|---|---|
| Services agreement + NDA template (Model A) | €500 | €1,500 | Phase 0 |
| DPA drafting | €1,500 | €3,500 | Phase 1 |
| ToS + privacy notice | €1,100 | €2,800 | Phase 1 |
| DPIA template review | €500 | €1,500 | Phase 3 |
| Incident notification template review | €200 | €400 | Phase 3 |
| Company structure advice | €300 | €1,000 | Gestor |
| Penetration test | €3,000 | €8,000 | Phase 4, or first enterprise customer |
| ISO 27001 Stage 1 + Stage 2 audit | €5,000 | €12,000 | Phase 4, micro-entity scope |
| ISO consultant *(optional — your experience may make this unnecessary)* | €0 | €8,000 | Phase 4 |
| **One-off total, Model A** | **€800** | **€2,500** | |
| **One-off total, Model B (Phases 0–3)** | **€4,100** | **€10,700** | |
| **One-off total, Model C (+ Phase 4)** | **€12,100** | **€30,700** | |

### Recurring annual

| Item | Low | High |
|---|---|---|
| Cyber liability insurance | €800 | €2,500 |
| Professional indemnity insurance | €400 | €1,500 |
| Secrets manager | €0 | €600 |
| Log storage / monitoring | €0 | €1,200 |
| Counsel retainer / ad hoc | €500 | €2,000 |
| External DPO **(only if required)** | €3,000 | €8,000 |
| ISO 27001 surveillance audit (years 2, 3) | €2,000 | €4,000 |
| **Recurring, Model B, no DPO** | **€1,700** | **€7,800** |
| **Recurring, Model B, with DPO** | **€4,700** | **€15,800** |
| **Recurring, Model C, with DPO** | **€6,700** | **€19,800** |

### Per-customer

| Item | Monthly |
|---|---|
| Hetzner (server + volume + IPv4) | €5.69 |
| eSIM / number | €2–5 |
| Fireworks tokens | €3–8 |
| Backup storage | €0.50–2 |
| **Total** | **€11–21** |

---

## 5. Break-even, Model B

Assumptions: €60/month price, €16/month average cost → **€44/month contribution**.

| Scenario | Year-1 cash cost | Customers to break even on cash | Customers to break even incl. your time @ €300/day |
|---|---|---|---|
| Model B, no DPO, low estimate | €5,800 | **11** | **60** |
| Model B, no DPO, high estimate | €18,500 | **35** | **110** |
| Model B, with DPO, high estimate | €26,500 | **50** | **125** |

**Reading this honestly:** Model B needs **30–50 customers** to be a real business rather than an expensive hobby. If that number feels implausible for your market and your appetite for sales work, [01](01-program-plan.md)'s recommendation stands — Model A, priced properly, with no ongoing data-processing relationship.

Model A break-even at €800 setup cost and €600 average price: **2 customers.** That difference is the entire argument.

---

## 6. Sequencing summary

| When | Do | Don't |
|---|---|---|
| **Now** | Genericise runbook, build automation, draft Model A agreement, find 3 paying pilots | Don't engage counsel for a full DPA yet |
| **After 3 pilots paid** | Assess: did anyone ask for managed hosting? | Don't assume they will |
| **If yes** | Phase 1 legal + Phase 2 technical, in parallel | Don't take a Model B customer before insurance is bound |
| **If no** | Stay in Model A. Raise prices. Improve automation | Don't build Model B compliance speculatively |
| **When a customer demands certification** | Phase 4 | Don't certify before someone asks and is willing to pay for it |
