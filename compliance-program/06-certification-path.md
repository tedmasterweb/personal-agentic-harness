# 06 — Certification Path

---

## 1. Should you certify at all?

**Not yet.** Certify when a customer or insurer demands it and is willing to pay a price that reflects it — not speculatively.

The argument for waiting is concrete: ISO 27001 costs €12,000–30,000 and 6–12 months, and its main commercial function is to answer procurement questionnaires. Small practices — a two-person therapy clinic, a solo *abogado* — mostly do not run procurement questionnaires. They ask "is my data safe, and what happens if it isn't?", which a signed DPA, a trust page, and insurance answer perfectly well.

The point at which certification starts paying for itself:

- A customer's own compliance function or professional body asks for evidence rather than assurances
- You want to sell to clinics, chambers, or firms above roughly 20 staff
- An insurer offers materially better terms with it
- A customer invokes Art. 28(3)(h) audit rights and you'd rather hand over a certificate than host an audit

That last one is underrated. **The audit-rights clause is where certification does the most work** — one certificate satisfies every customer's audit right simultaneously, instead of you fielding individual audits as a sole operator.

---

## 2. ISO 27001 vs SOC 2

| | **ISO/IEC 27001:2022** | **SOC 2 Type II** |
|---|---|---|
| Origin | International standard (ISO/IEC) | US, AICPA |
| Output | Certificate | Attestation report |
| Recognition | Strong in EU | Strong in US, weaker in EU |
| Your customers | Spanish/EU professionals — **recognise ISO** | Would mostly not know what it is |
| Your background | **You've done it before** | New learning curve |
| Cost | €12,000–30,000 year 1 | Typically $20,000–60,000 with tooling |
| Duration | 6–12 months | 3–12 month observation window |

**ISO 27001 is the clear answer**, for three independent reasons: your customers are EU-based, ISO is the recognised standard in that market, and you have already been through it. SOC 2 would only matter if you pivoted to US customers.

Note ISO/IEC 27001:**2022** is the current version — the transition from 27001:2013 has closed, so there's no version decision to make. Annex A has 93 controls across four themes (organisational, people, physical, technological), down from 114 in 14 domains — if your prior experience was on the 2013 version, expect the restructure but not a fundamentally different exercise.

**Consider also ISO/IEC 27701** (privacy information management, extends 27001) as a later addition. For a business whose entire pitch is data protection, it's a better second certificate than most alternatives — and notably, Fireworks is described as holding it, which gives you a supply-chain story too.

---

## 3. ISMS scope

Scope tightly. Scope creep is the main driver of cost and effort in a small certification.

**In scope:**
- The managed AI assistant service (Model B) — provisioning, operation, support, de-provisioning
- Infrastructure under your administration (Hetzner VMs, volumes, secrets vault, log collector)
- Your own devices used for administration
- Customer data processing

**Out of scope (state explicitly):**
- Customer-owned infrastructure (Model A engagements)
- Your family's personal instance
- Sub-processors' own operations — covered by supplier management controls, not your ISMS

A tight scope statement might read: *"The information security management system supporting the provision of managed private AI assistant services to professional clients, including infrastructure provisioning, operation, support and decommissioning, at [location]."*

---

## 4. Mandatory clauses and key Annex A controls

Clauses 4–10 are mandatory regardless of scope — context, leadership, planning, support, operation, performance evaluation, improvement. You'll know the drill.

Annex A controls likely to attract the most auditor attention **given your specific model**:

| Control theme | Why it matters here |
|---|---|
| **A.5.15 / A.5.18 Access control, access rights** | The core issue — your administrative access to customer data. See [03](03-security-architecture.md) |
| **A.5.19–A.5.23 Supplier & cloud services** | Hetzner, Fireworks, eSIM provider. Your sub-processor management |
| **A.5.7 Threat intelligence** | Monitoring advisories for Hermes, signal-cli, Docker, dependencies |
| **A.5.24–A.5.28 Incident management** | Ties directly to Art. 33 breach obligations |
| **A.5.30 ICT readiness for continuity** | The sole-operator single point of failure |
| **A.8.2 Privileged access rights** | Root access, break-glass, escrow |
| **A.8.5 Secure authentication** | SSH key-only auth (already done), vault access |
| **A.8.10 Information deletion** | Your erasure tooling — the agent-memory problem |
| **A.8.12 Data leakage prevention** | Prompt injection, agent tool scope |
| **A.8.15 Logging** | Your audit logging build |
| **A.8.16 Monitoring activities** | Detection capability |
| **A.8.24 Use of cryptography** | LUKS, TLS, key management policy |
| **A.8.32 Change management** | How you patch and update customer instances |

The good news: **Phase 2 and Phase 3 in [01](01-program-plan.md) already build most of the evidence** these controls require. If you sequence it as recommended — write the documentation as you build the controls — certification becomes largely an evidence-assembly and audit-support exercise rather than a fresh project.

---

## 5. Timeline

| Stage | Duration | Notes |
|---|---|---|
| Gap analysis against Annex A | 2–3 weeks | Self-performed given your background |
| ISMS documentation completion | 4–8 weeks | Largely done if Phase 3 complete |
| **ISMS operating period** | **3–6 months minimum** | **The unavoidable wait.** Auditors need evidence the ISMS actually runs — records, reviews, incidents handled |
| Internal audit | 1–2 weeks | Must be independent of the work audited; as a sole operator this is a genuine problem — **budget for an external internal-auditor** (~€1,500–3,000) |
| Management review | 1 week | Documented, even as a sole operator |
| Penetration test | 2–4 weeks incl. remediation | Usually expected |
| Stage 1 audit (documentation) | 1 day + scheduling | |
| Stage 2 audit (implementation) | 2–3 days + scheduling | |
| Certificate issued | 2–6 weeks after Stage 2 | |
| **Total** | **6–12 months** | |

**The 3–6 month operating period is the hard floor.** You cannot compress it, which is the strongest argument for starting Phase 2/3 documentation early even if you defer certification — it starts the clock on evidence accumulation without committing to the audit cost.

**Sole-operator wrinkle:** ISO 27001 requires internal audits performed with objectivity and impartiality. One person cannot credibly audit their own ISMS. Plan to bring in an external internal-auditor — this is a real, recurring cost that first-time solo certifiers often miss, and certification bodies do check it.

---

## 6. Ongoing obligations

Certification is a three-year cycle:

- **Year 1:** certification audit (Stage 1 + 2)
- **Years 2 and 3:** surveillance audits, €2,000–4,000 each
- **Year 4:** recertification, similar cost to initial
- **Continuously:** internal audits, management reviews, risk reassessment, corrective actions

Budget **€2,000–4,000/year ongoing** plus your time. Letting a certificate lapse after advertising it is worse commercially than never having had one, so treat this as a permanent commitment before you start.

---

## 7. Cheaper intermediate options

If you need *some* credential before you can justify full certification:

- **ENS (Esquema Nacional de Seguridad)** — Spanish national security framework. Relevant if you ever sell to Spanish public sector; not otherwise
- **Cyber Essentials-style self-assessment** — UK scheme, limited EU recognition, but cheap and gives a structured baseline
- **A published, detailed trust page plus a completed CAIQ or SIG-lite questionnaire** — costs nothing but your time, and satisfies a surprising number of small-customer due diligence requests
- **Third-party security review** (not a certification) — a few thousand euros for an independent assessment you can cite

**Recommendation:** the trust page plus a pre-completed security questionnaire is the right first step. It handles most small-practice due diligence at near-zero cost, and it directly produces material you'll reuse in a future certification.
