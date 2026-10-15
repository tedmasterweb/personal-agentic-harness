# 02 — GDPR Obligations

*Assumes Model B (managed service). Under Model A most of this falls away — see [01](01-program-plan.md) §1.*

---

## 1. Role mapping — get this right first, everything derives from it

| Data | Controller | Processor | Sub-processors |
|---|---|---|---|
| Customer's client conversations with the agent | **The customer** (therapist/lawyer/firm) | **You** | Hetzner, Fireworks, eSIM provider |
| Your customer's own contact & billing data | **You** | Your accounting/payment tools | Stripe/gestor/etc. |
| Server logs, access logs you generate | **You** (for security purposes) | — | Hetzner |

The critical line: **for the sensitive material — a therapist's session notes, a lawyer's client matters — you are the processor and they are the controller.** They decide purposes and means; you provide the infrastructure. This means:

- You may only process on **documented instructions** from the controller (Art. 28(3)(a))
- You need a **written DPA with every single customer** before processing begins (Art. 28(3))
- You cannot engage sub-processors without **prior specific or general written authorisation** (Art. 28(2))
- You must **assist the controller** with data subject requests, DPIAs, and breach notification (Art. 28(3)(e)(f))
- On termination you must **delete or return all data** and prove it (Art. 28(3)(g))

## 2. Sub-processor register

Maintain this as a living document; publish it; notify customers of changes with a right to object.

| Sub-processor | Role | Location | Transfer mechanism | Certifications |
|---|---|---|---|---|
| **Hetzner Online GmbH** | Hosting, storage | Nuremberg / Falkenstein, **DE** | None needed — EU/EEA | ISO/IEC 27001:2022 (covers all hosting services and DCs incl. Nuremberg, Falkenstein, Helsinki); BSI C5 Type 2; DPA signable electronically at `accounts.hetzner.com/account/dpa` |
| **Fireworks AI** | LLM inference | **US** | **SCCs** — their public DPA incorporates Commission Implementing Decision (EU) 2021/914 + Swiss addendum | SOC 2 Type II; HIPAA. Trust centre at `trust.fireworks.ai` |
| **Fireworks' own sub-processors** | Underlying compute | US, **Japan** (AWS), plus GCP, Oracle Cloud | Flows through Fireworks' DPA Schedule 4 | Inherited |
| **eSIM / number provider** | Signal registration SMS | TBD | TBD | **Not yet selected — assess before choosing** |
| **Signal Foundation** | Message transport | US | Message *content* is E2EE and not accessible to Signal; metadata is. Arguably not a processor for content — **confirm with counsel** | — |

### Actions

- [ ] Sign Hetzner's DPA (electronic, straightforward)
- [ ] Execute Fireworks' DPA. **Check carefully:** their DPA is described as incorporating SCC **Module Two** (controller→processor). As a processor engaging them as a *sub*-processor, you likely need **Module Three** (processor→processor). Raise with counsel and with Fireworks — this is a real gap, not a formality
- [ ] Complete a **Transfer Impact Assessment** for the US transfer (see §3)
- [ ] Select eSIM provider *with GDPR posture as a selection criterion*, not price alone
- [ ] Get counsel's view on Signal's status given E2EE

## 3. International transfers — the live risk

Fireworks is in the US. Two mechanisms exist:

**EU–US Data Privacy Framework.** Valid as of mid-2026: the Commission's 2023 adequacy decision stands, and the EU General Court dismissed the Latombe challenge on 3 September 2025 (T‑553/23). **But** an appeal is pending before the CJEU as **Case C‑703/25 P**, filed 31 October 2025, with no hearing date announced as of May 2026.

**Standard Contractual Clauses.** Fireworks' published DPA uses SCCs, which is the more robust position — SCCs survive a DPF invalidation, as they did after Schrems II.

### Recommendation

**Rely on SCCs, not DPF, and document a Transfer Impact Assessment.** If the CJEU annuls the adequacy decision on appeal, anyone relying on DPF alone has an immediate, urgent problem; SCC-based transfers continue (subject to the TIA holding up). Since Fireworks already offers SCCs, take them.

The TIA needs to address US surveillance law exposure (FISA 702, EO 12333) against the nature of the data — which, for therapist and lawyer customers, is **special category and/or professionally privileged**. Be aware this is exactly the scenario where a TIA is hardest to pass. Supplementary measures to consider and document:

- Fireworks' zero-retention posture for open models (data in volatile memory for request duration only) — materially strengthens the assessment
- Whether prompts can be minimised or pseudonymised before transmission
- **Whether an EU-hosted inference provider removes the transfer question entirely** — worth pricing. This may be the single highest-leverage change available to you for this customer segment, and it is worth investigating before committing to Fireworks for regulated customers

## 4. Records of Processing Activities (Art. 30)

As a processor you must maintain Art. 30(2) records. The small-organisation exemption in Art. 30(5) **does not help you** — it disapplies where processing involves special category data, which yours does.

Minimum content per Art. 30(2):

- Name and contact details of you (processor), each controller you act for, and any DPO
- Categories of processing carried out for each controller
- Third-country transfers, with the safeguard used
- General description of technical and organisational security measures (Art. 32)

**Effort:** 2–4 days given a template and your ISO background. Keep it in version control alongside the code — it changes whenever the sub-processor list or architecture changes.

## 5. DPIA (Art. 35)

**Almost certainly mandatory.** Triggers present:

- Processing of **special category data** (Art. 9 — health data, via therapists)
- **New technologies** (Art. 35(1) explicitly names this)
- Processing likely to result in high risk to rights and freedoms

Formally the DPIA obligation sits with the **controller** (your customer), not you — but Art. 28(3)(f) requires you to *assist* them, and practically, a small practice will not have the capability. Producing a **template DPIA that customers adapt** is both a compliance asset and a genuine sales differentiator: you arrive with the homework done.

Check the **AEPD's published list** of processing operations requiring a DPIA and map against it explicitly in the document.

**Effort:** 5–8 days for a good template, given your experience. Have counsel review it once.

## 6. Data subject rights (Art. 12–22)

Your obligation is to *enable* the controller to respond, within their timelines. Design decisions this forces:

| Right | What you must be able to do |
|---|---|
| Access (Art. 15) | Export a data subject's conversation history from `state.db` in intelligible form |
| Erasure (Art. 17) | Delete specific records — **note the agent's memory system and session history make this non-trivial; verify erasure actually removes data from `MEMORY.md`, `USER.md`, session JSON, *and* any compaction summaries** |
| Portability (Art. 20) | Structured, machine-readable export |
| Rectification (Art. 16) | Correct stored personal data, including agent memories |

**This is a real engineering requirement, not paperwork.** Build and test the export/erasure tooling in Phase 2. A self-improving agent that writes its own memory files is genuinely harder to erase from than a normal database — budget for it, and test that erasure survives the Curator's consolidation cycle.

## 7. Do you need a DPO? (Art. 37)

Mandatory if core activities involve either (a) regular and systematic monitoring of data subjects on a large scale, or (b) **processing of special category data on a large scale**.

Your position is genuinely ambiguous:
- *For* requirement: your core activity is processing others' data, and it includes health data
- *Against*: "large scale" is assessed on volume, data subject numbers, duration, geography. Thirty small practices is plausibly **not** large scale

**This is a specific question to put to counsel in Phase 1.** It matters a lot financially: an external fractional DPO runs roughly €3,000–8,000/year, which materially changes the unit economics in [01](01-program-plan.md) §2. Note also that Spain's LOPDGDD (Ley Orgánica 3/2018) imposes DPO requirements on certain entity types beyond the GDPR baseline — worth checking whether any apply to you or, importantly, to your *customers*.

## 8. Personal data breach procedure (Art. 33)

As processor: notify the controller **"without undue delay"** after becoming aware (Art. 33(2)). The 72-hour clock in Art. 33(1) is the *controller's* obligation to the supervisory authority — your job is to give them enough time and information to meet it.

Minimum viable procedure, to be written in Phase 3:

1. **Detection** — how would you even know? (This is why audit logging in [03](03-security-architecture.md) is not optional)
2. **Triage** — severity, scope, which customers affected
3. **Notification** — customer contact within a defined internal SLA. **Recommend committing to 24 hours in the DPA**; it is a strong selling point and forces you to build detection
4. **Documentation** — facts, effects, remedial action, per Art. 33(5)
5. **Support** — assist the controller's own notification to the AEPD and, where required, to data subjects (Art. 34)

Be aware of the escalation for your customer segment: for a Spanish *abogado* or healthcare professional, unauthorised disclosure of client confidences can carry consequences under **professional secrecy rules and potentially the Código Penal (Art. 199)** — not merely administrative fines. Confirm the specifics with counsel, but understand that your customers' exposure is more severe than a typical SME's, which is precisely why they'll scrutinise your terms.

## 9. Retention and deletion

Define and document, per data category:

| Data | Retention | Deletion mechanism |
|---|---|---|
| Conversation history / session data | Controller-defined; offer a configurable default (e.g. 90 days) | Existing `hermes sessions prune` + verified erasure tooling |
| Agent memory files | Controller-defined | Manual review + tooling — **highest-risk category for incomplete deletion** |
| Your access/audit logs | Recommend 12 months (security purpose, your own controller role) | Automated rotation |
| Backups | **Currently none** — this is a customer-facing decision under Model B; the "accepted data loss" stance from the personal build is not sellable | To be designed |
| Instance on termination | Delete within 30 days, certificate of deletion issued | Automated de-provisioning + LUKS volume destruction |

**Note:** under Model B you cannot carry over the "no backups, I can live with losing it" decision from your own build. A customer losing their entire case history because you chose not to back up would be an availability failure under Art. 32(1)(b)-(c) — and commercially fatal. Backup design becomes a required Phase 2 workstream, with its own encryption and retention questions.
