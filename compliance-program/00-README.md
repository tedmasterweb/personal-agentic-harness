# Compliance & Commercialisation Program — Private AI Assistant for Regulated Professionals

**Owner:** Ted
**Status:** Planning / pre-decision
**Created:** August 2026

---

## What this is

A plan for turning the working Hermes build (see `../hermes-build-runbook.md`) into something you can legitimately sell to therapists, lawyers, and small EU businesses — people who have an *actual blocking reason* to avoid ChatGPT and Claude, rather than a preference.

It exists because of one problem identified in conversation: **in the obvious version of this business, you personally hold root SSH, the LUKS passphrase, and the Signal Registration Lock PIN for every customer's box.** For a customer subject to professional secrecy, that makes you an unaudited party with technical access to privileged communications. That is a real liability, not a paperwork detail, and it drives almost everything in these documents.

## Read in this order

| # | Document | What it answers |
|---|---|---|
| 01 | [Program plan](01-program-plan.md) | **Start here.** Three operating models with radically different compliance burdens; unit economics; go/no-go gates |
| 02 | [GDPR obligations](02-gdpr-obligations.md) | Controller/processor mapping, ROPA, DPIA, sub-processors, international transfers, breach procedure |
| 03 | [Security architecture](03-security-architecture.md) | Technical remediation: the root-access problem, secrets, audit logging, break-glass |
| 04 | [Customer documents](04-customer-documents.md) | DPA, ToS, privacy notice, security page — what's needed, who drafts it |
| 05 | [RACI & estimates](05-raci-and-estimates.md) | Who does what, effort in days, cost in euros |
| 06 | [Certification path](06-certification-path.md) | ISO 27001 vs SOC 2, ISMS scope, timeline, whether it's worth it |
| 07 | [Minimum viable compliance](07-minimum-viable-compliance.md) | **The operative plan.** Lean Model B: hard floor vs deferrable, with triggers |

### Templates

| Document | Status |
|---|---|
| [Data Processing Agreement](templates/data-processing-agreement.md) | **Draft for counsel review** — includes a briefing note to keep the engagement cheap |

## Decision record

**August 2026 — Model B (managed service) selected.** Model A (setup-only, customer owns infrastructure) was analysed in [01](01-program-plan.md) and rejected: requiring non-technical customers to own and manage a Hetzner account, a Fireworks key, and a LUKS passphrase doesn't match what people expect to buy, regardless of its compliance advantages.

Scope is constrained to a bootstrapped budget. **[07-minimum-viable-compliance.md](07-minimum-viable-compliance.md) is therefore the operative plan** — documents 01–06 remain the fuller analysis and the reference for what gets un-deferred later.

## The headline finding, before you read further

**€100 one-time does not work if you host the infrastructure.** Per-customer running cost is roughly €11–21/month (Hetzner + eSIM + tokens + backups). A €100 one-time fee is fully consumed in 5–9 months, and that is *before* any compliance cost, any support time, and any of your own labour. See [01-program-plan.md](01-program-plan.md) for the model.

Given the Model B decision, **pricing must be recurring: €40–80/month**, with or without a setup fee. At €60/month the contribution is ~€44/customer/month, and the lean compliance scope in [07](07-minimum-viable-compliance.md) breaks even on cash at **5–14 customers** — a plausible target for a niche reached through professional associations, and the number that makes this viable at all.

## Assumptions this plan makes

- You are established in Spain (Canary Islands); lead supervisory authority is the **AEPD**.
- Target customers are EU-based, primarily Spain.
- Customers include some processing **Article 9 special category data** (health data, via therapists). This materially raises the bar and is assumed throughout.
- You have prior ISO 27001 and ISO 9001 experience, so ISMS documentation effort is estimated lower than for a first-timer.
- You are a sole operator with no employees at the start.

## Health warning on numbers and legal content

Every cost figure is a **planning estimate** for budgeting, not a quote. Ranges are wide deliberately. Get real quotes before committing.

Nothing here is legal advice. The GDPR structure described is the standard pattern and the article references are accurate, but the application to your specific circumstances — particularly Spanish professional-secrecy law for *abogados* and healthcare practitioners, and whether you need a DPO — needs a Spanish data protection lawyer. Budget for that; it is line-itemed in [05](05-raci-and-estimates.md).
