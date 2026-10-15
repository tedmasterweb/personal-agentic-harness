# 07 — Minimum Viable Compliance

**Decision taken:** Model B (managed service). Model A rejected — the friction of customer-owned accounts doesn't match what people expect to buy.

**Constraint:** bootstrapped. This document scopes Model B down to what is genuinely defensible on a startup budget, and marks explicitly what is being deferred and what triggers un-deferring it.

---

## 1. The principle you can legitimately lean on

GDPR Art. 32(1) requires security measures "appropriate to the risk," taking into account **"the state of the art, the costs of implementation and the nature, scope, context and purposes of processing."** Proportionality is written into the regulation. A sole operator with eight customers is not held to the same standard as a scale-up with eight hundred.

Two limits on how far that gets you:

- **Special category data raises the floor.** Health data via therapists means the "risk" side of the proportionality test is high even when volume is low. You get less latitude than a startup processing, say, restaurant bookings.
- **Some obligations are binary, not proportionate.** You either have a DPA or you're processing unlawfully. There is no small-company version of Art. 28(3).

So the strategy is: **be rigorous about the binary obligations, proportionate about the graduated ones, and document why.** An auditor or the AEPD will accept "we assessed this as adequate for our scale and risk profile, here's the reasoning" far more readily than silence.

---

## 2. The hard floor — cannot be cut at any budget

| # | Item | Why it's non-negotiable | Lean cost |
|---|---|---|---|
| F1 | **Signed DPA with every customer** | Art. 28(3). Processing without one is unlawful regardless of how good your security is | €800–1,500 |
| F2 | **Cyber liability + professional indemnity insurance** | Not a compliance item — an existential one. One incident without cover, against privileged-data exposure, ends you personally | €1,200–4,000/yr |
| F3 | **Breach detection capability** | You cannot meet Art. 33 if you'd never know. Also the thing that makes F1's notification clause honest | €60–300/yr |
| F4 | **Working erasure + export** | You will contractually promise deletion. Promising what you can't perform is misrepresentation on top of an Art. 17 failure | Time only |
| F5 | **ROPA** | Art. 30(2). The small-org exemption in Art. 30(5) is disapplied by special category data | Time only |
| F6 | **Backups with tested restore** | Art. 32(1)(c) availability. Also: losing a therapist's case history is commercially terminal | €50–120/yr |
| F7 | **DPO determination** | Not the DPO — the *answer*. See §5; this single question governs your recurring cost | €200–400 |
| F8 | **Privacy notice + ToS** | Art. 13/14 for your own controller-role data; ToS for basic commercial protection | €500–1,000 |

**Hard floor total: roughly €2,800–7,300 year one**, of which €1,200–4,000 is insurance.

---

## 3. Deferrable — with explicit triggers

Defer these deliberately and write down the trigger. Undocumented deferral is negligence; documented deferral is risk management.

| Item | Defer until | Cost when triggered |
|---|---|---|
| ISO 27001 certification | A customer or insurer demands it in writing | €12,000–30,000 |
| Penetration test | First customer >10 staff, or pre-certification | €3,000–8,000 |
| External DPO | Only if F7 says mandatory — **not optional if it does** | €3,000–8,000/yr |
| Managed SIEM | >20 customers, or first real incident | €1,000+/yr |
| Bespoke (non-template) DPA | A customer's counsel rejects your template | €1,500–3,500 |
| Polished DPIA template | Third therapist customer, or first customer who asks | 5–8 days |
| External internal-auditor | Only needed for certification | €1,500–3,000 |
| Formal risk treatment plan | Certification, or >20 customers | 5–8 days |
| 24h breach SLA in DPA | Start at 48h; tighten when detection is proven | — |

---

## 4. Lean technical build — Phase 2 minimum

Cutting [03](03-security-architecture.md)'s roadmap to what actually earns its keep at 5–20 customers:

| Control | Lean implementation | Days |
|---|---|---|
| **C1 LUKS custody** | Option 2 (customer-held + sealed escrow). Escrow in the secrets vault, break-glass emits email to customer. No HSM, no ceremony | 2–3 |
| **C2 Audit logging** | `auditd` on each instance → rsyslog to one dedicated €5/mo Hetzner box with separate credentials. Not a SIEM. Alert on interactive login + escrow access via simple cron + email | 4–6 |
| **C3 Secrets** | Bitwarden Secrets Manager or self-hosted Infisical. Per-customer scoping, documented rotation on offboarding | 3–5 |
| **C4 Break-glass** | Written procedure + the C2 alert. The control is the notification, not the tooling | 1–2 |
| **C5 Backups** | `borg` or `restic` to Hetzner Storage Box, encrypted, nightly. **Test restore quarterly and log it** | 4–6 |
| **C6 Export/erasure** | Scripts against `state.db`, session JSON, and memory files. Must survive the Curator's consolidation cycle — **test this specifically** | 6–10 |
| **C7 One VM per customer** | Already the plan. Free — it's how you'd provision anyway | — |
| **C8 Provisioning** | Terraform + the existing cloud-init. Idempotent, logged | 5–8 |
| **C9 De-provisioning** | Destroy server + volume, emit deletion certificate | 2–3 |
| **C10 Patching** | Documented monthly cadence + `unattended-upgrades` for security patches | 1–2 |
| **C12 Prompt injection** | **Ship regulated customers with terminal/code-exec disabled by default.** Free, and removes the hardest question in your DPIA | 1 |

**Lean Phase 2: 29–46 days** (vs 31–56 full). The saving is modest because most of this genuinely is the floor — the real savings are in Phases 1, 3 and 4.

Note C12 is a *cost saver*: disabling terminal access for this segment removes an entire risk narrative you'd otherwise have to assess, document, and defend. Most therapists want a conversational assistant, not cron jobs.

---

## 5. Do this first — the €300 question that governs everything

**Get the DPO determination (F7) answered before anything else.**

It's a single scoped question to counsel, maybe 1–2 hours of their time. It determines whether your recurring cost is **€1,700–7,800/yr** or **€4,700–15,800/yr** — which at €44/month contribution is the difference between break-even at ~11 customers and break-even at ~30.

Frame the question precisely to keep it cheap:

> I intend to act as a data processor providing managed AI assistant infrastructure to Spanish healthcare and legal professionals. Volume: 5–50 small practices. Processing includes Art. 9 special category data (health) and material subject to professional secrecy. Sole operator, established in Spain. **Is a DPO mandatory under GDPR Art. 37 and/or LOPDGDD?** If borderline, what factors would tip it?

Ask two further things in the same engagement, since you're paying for the call:

- Does Fireworks' DPA (SCC **Module Two**, controller→processor) work when you engage them as a **sub**-processor, where Module Three would normally apply? See [02](02-gdpr-obligations.md) §2
- Any Spanish professional-secrecy rules that restrict *your customers* from using third-party processors for privileged material at all — because if *abogados* are effectively barred, that segment evaporates and you should know now, not after building for it

That third question is the cheapest possible way to find out whether half your target market is legally reachable.

---

## 6. Lean cost summary

| | Year 1 cash | Recurring |
|---|---|---|
| Hard floor (§2) | €2,800–7,300 | €1,400–4,700 |
| Full Model B ([05](05-raci-and-estimates.md)) | €5,800–18,500 | €1,700–7,800 |
| **Saving** | **~€3,000–11,000** | **~€300–3,100** |

Break-even at €60/month, €44 contribution, hard-floor scope: **5–14 customers** on cash, versus 11–35 for the full build.

**That is a genuinely different business.** Five to fourteen customers is plausible for a niche you can reach through professional associations and word of mouth. Thirty-five is a sales operation.

---

## 7. What you must not tell yourself

Three failure modes worth naming, since "good enough" is doing a lot of work in this plan:

**"We'll add the DPA once we have customers."** Processing without it is the unlawful bit. It's also the cheapest item on the list. Do it first.

**"Insurance can wait until revenue justifies it."** The scenario insurance exists for is the one that happens before you have revenue. Bind it before the first customer's data lands.

**"We'll figure out deletion when someone asks."** Hermes writes its own memory files and consolidates them on a schedule. Erasure that works on `state.db` but leaves fragments in `MEMORY.md` or a compaction summary is a failed erasure you'd report as successful. Build and test it before you promise it.

Everything else on the deferred list is a legitimate business judgement. These three are not.
