# 04 — Customer-Facing Documents

---

## 1. Inventory

| Doc | Needed for | Who drafts | Effort | Cost |
|---|---|---|---|---|
| **Services agreement + NDA** (Model A) | Every setup-only engagement | Counsel, from template | 1 day review | €500–1,500 |
| **Data Processing Agreement** (Model B) | Every managed customer, before processing | **Counsel — do not self-draft** | 2–3 days your input | €1,500–3,500 |
| **Terms of Service** | Model B | Counsel | 1–2 days your input | €800–2,000 |
| **Privacy notice** (your own controller role) | Website, customer data | You, counsel review | 2 days | €300–800 |
| **Sub-processor list** (public) | Art. 28(2) transparency | You | 0.5 day | €0 |
| **Security overview / trust page** | Sales asset | You | 2–3 days | €0 |
| **Template DPIA** | Customer assistance, Art. 28(3)(f) | You, counsel review | 5–8 days | €500–1,500 review |
| **Onboarding pack** | Handover, key custody | You | 2–3 days | €0 |
| **Deletion certificate template** | Offboarding evidence | You | 0.5 day | €0 |
| **Incident notification template** | Breach response readiness | You, counsel review | 1 day | €300 |

---

## 2. The DPA — clauses that need your specific attention

Counsel will produce the standard Art. 28 structure. These are the ones where *your* architecture forces a decision, and where you should arrive with a position rather than let boilerplate decide:

**Sub-processor authorisation.** General authorisation with a notification period (30 days is common) and a right to object. Specific authorisation per sub-processor is cleaner for the customer but means re-papering every customer when you change providers. **Recommend general authorisation with published list + email notification.**

**Breach notification SLA.** Art. 33(2) says "without undue delay." **Recommend committing to a specific 24 hours** — it's a strong differentiator against larger vendors who commit to vaguer terms, and it forces you to actually build detection (C2 in [03](03-security-architecture.md)).

**Your access rights.** This is the clause your customer segment will read most carefully. Spell out: the break-glass procedure, that access generates a notification to them, that it is logged, that logs are available to them on request, and the defined circumstances in which you'd use it (incident response, customer-requested support, legal obligation). **Vagueness here loses deals.**

**Audit rights (Art. 28(3)(h)).** Customers have a right to audit. For a sole operator, unlimited on-site audit rights are unmanageable. Standard mitigation: satisfy audit obligations by providing documentation and certifications, with on-site audits limited to once annually, on reasonable notice, at the customer's cost. Note this is exactly the clause where an ISO 27001 certificate does the most work — see [06](06-certification-path.md).

**Return and deletion on termination.** Commit to a timeframe (30 days) and to issuing a deletion certificate. Note the technical dependency: your erasure tooling (C6) must actually work, including agent memory files and backups.

**Liability cap.** Get counsel's view. Note that a cap set at, say, 12 months' fees (~€720 at €60/month) against a customer's potential exposure for a privileged-data breach is a mismatch they may push back on — and it is a large part of why **insurance matters more than the cap does**. Expect this to be negotiated by any customer with a competent adviser.

---

## 3. Insurance — do not skip

This is the single most important non-technical line item, and it should be bound **before the first Model B customer**, not after.

| Cover | Why | Rough annual cost |
|---|---|---|
| **Cyber liability** | Breach response costs, notification, forensics, regulatory defence | €800–2,500 |
| **Professional indemnity** | Claims arising from your professional services | €400–1,500 |

Estimates are for a Spanish micro-entity; get real quotes via a broker. **Ask specifically** whether the policy covers: processing of special category data, claims arising from sub-processor failure, and regulatory fines (often excluded or limited — GDPR fines are uninsurable in some jurisdictions; confirm for Spain).

A customer's adviser will ask whether you carry cover. "No" ends the conversation with anyone serious.

---

## 4. Trust page — what to publish

Public page, linked from sales material. Contents:

- Sub-processor list with locations and transfer mechanisms
- Security overview (the honest claim from [03](03-security-architecture.md) §8)
- Certifications held by you and by your sub-processors (Hetzner ISO 27001:2022 + BSI C5; Fireworks SOC 2 Type II + HIPAA) — **clearly distinguishing which are yours and which are your suppliers'.** Implying your suppliers' certifications are your own is a common and damaging overclaim
- Where data is stored (Germany) and where it is processed (Germany + US inference)
- Contact for security issues and data protection queries
- Link to DPA template

**Publishing the honest version — including that inference happens in the US under SCCs — is better than omitting it.** Customers in this segment will find out, and finding out later reads as concealment. If you move to an EU inference provider (see [02](02-gdpr-obligations.md) §3), this page becomes dramatically stronger, which is another argument for investigating that.

---

## 5. Onboarding pack

Handed over at the end of every install. Doubles as your evidence that you discharged your obligations.

1. **Credential handover record** — what was handed over, when, acknowledged by the customer. Critical under Model A, where it marks the point your responsibility ends
2. **LUKS passphrase custody choice** — which option from [03](03-security-architecture.md) §3 they selected, signed
3. **Recovery instructions** — plain-language version of the `hermes-unlock` procedure
4. **What this system can and cannot do** — set expectations on model quality, vision limitations, availability
5. **Their obligations** — keeping the number active, safeguarding credentials, their own controller duties
6. **Support scope and escalation** — what's included, response times, how to reach you
7. **Signed DPA and services agreement** copies

---

## 6. A note on the sales conversation

For this segment, the compliance documentation *is* the product differentiator. A therapist choosing between ChatGPT and you is not comparing model quality — they will lose that comparison. They are comparing "a US consumer product whose terms I don't understand and whose data handling my professional body may take a dim view of" against "a documented processor relationship with a signed DPA, an EU-hosted instance, and someone who answers the phone."

Lead with the DPA and the trust page, not the technology. The build is the delivery mechanism; the compliance posture is what you are actually selling.
