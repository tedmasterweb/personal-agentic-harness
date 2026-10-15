# 01 — Program Plan

---

## 1. The decision that determines everything else

Before any compliance work, pick an operating model. The three below differ by roughly **an order of magnitude in compliance cost** and they are not equally viable.

### Model A — Setup-only (consultant)

You install and configure on infrastructure the **customer owns**: their Hetzner account, their Fireworks key, their eSIM, their LUKS passphrase. You hand over all credentials at the end and **retain no access**. Optional: a separate, explicitly-consented support engagement.

- **Your GDPR role:** arguably not a processor at all for their client data — you're a consultant doing a one-off installation. You may briefly access personal data during setup; handle with a short services agreement and confidentiality clause.
- **Compliance burden:** low. No DPA chain to maintain, no sub-processor management, no ROPA covering customer client data, no DPIA obligation of your own.
- **Price point that works:** €400–1,500 one-time, depending on hand-holding.
- **The catch — and it's the one you already identified:** customers are bad at managing accounts and passwords. If they lose the LUKS passphrase, their data is gone. If the Pepephone-equivalent line lapses, the Signal account may be unrecoverable. You will get support calls regardless of what the contract says.

### Model B — Managed service (you host)

You own the infrastructure accounts and run instances on behalf of customers.

- **Your GDPR role:** **processor** for customer client data. Customer is controller. Full Article 28 obligations.
- **Compliance burden:** substantial. DPA with every customer, sub-processor disclosure and change notification, ROPA, DPIA, TOMs documentation, breach notification procedure, plus the access-control remediation in [03](03-security-architecture.md).
- **Price point required:** €40–80/month recurring, plus setup. See the unit economics below — anything less loses money.
- **The catch:** you hold access to privileged data. Solvable, but it is the work.

### Model C — Managed + certified

Model B plus ISO 27001 certification, so you can answer a procurement questionnaire without hand-waving.

- **When it's needed:** larger customers, insurers, or any customer whose own compliance function demands evidence rather than assurances.
- **Adds:** €10,000–25,000 first year and 6–12 months. See [06](06-certification-path.md).

### Decision — August 2026: Model B

The original recommendation here was to start with Model A and test demand cheaply. **That was rejected**, on the grounds that requiring non-technical customers to own and operate a Hetzner account, a Fireworks key, and a LUKS passphrase is not what people expect to buy — the friction outweighs the compliance advantage, and the segment least tolerant of that friction is exactly the one being targeted.

Model B it is, scoped to a bootstrapped budget. **See [07-minimum-viable-compliance.md](07-minimum-viable-compliance.md) for the operative plan** — what the hard floor actually is, what gets deferred, and what triggers un-deferring it.

The Phase 0 validation logic below still applies and is still worth doing — genericise, automate, find paying pilots — but pilots now run on your infrastructure under a DPA, which means the hard-floor items (DPA, insurance, breach detection) must be in place *before* the first pilot rather than after. That reorders the phasing: **the legal floor moves ahead of pilot delivery.**

---

## 2. Unit economics — why €100 doesn't work under Model B

### Per-customer monthly running cost

| Item | Monthly |
|---|---|
| Hetzner CX22 | €4.49 |
| 10 GB volume | €0.50 |
| IPv4 | €0.70 |
| eSIM / number (assumed, varies by provider) | €2–5 |
| Fireworks tokens (single user, GLM-5.2 class) | €3–8 |
| Backup storage (required under Model B — see [02](02-gdpr-obligations.md) §9) | €0.50–2 |
| **Total** | **€11–21** |

Your own build is running at roughly this cost today, so this is grounded, not speculative.

### What that means for pricing

| Price model | Outcome |
|---|---|
| €100 one-time, you host | **Loses money from month 6–9.** Every customer becomes a growing liability |
| €100 one-time, customer hosts (Model A) | Viable, but underprices your time — this is 3–6 hours of skilled work even automated |
| €400–1,500 one-time, customer hosts (Model A) | **Works.** Clean, no ongoing exposure |
| €20/month, you host | Gross margin €1–9/customer/month. Never recovers compliance cost |
| €40–80/month, you host (Model B) | **Works** — €21–69/month contribution. At 30 customers ≈ €7,500–25,000/year gross |

### Compliance cost recovery under Model B

Model B year-one cash cost (see [05](05-raci-and-estimates.md) §4) is **€5,800–18,500** — one-off legal and setup plus the first year of insurance, tooling and retainers — assuming no mandatory DPO. Total effort across Phases 0–3 is **77–130 days**.

At €60/month against ~€16/month cost, contribution is €44/customer/month. Ignoring your labour entirely: **11–35 customers just to recover year-one cash cost.** Include your time at a modest €300/day and it's **60–110 customers** before the program truly breaks even.

That is achievable in a niche market — but it means Model B needs a realistic target of *at least* 30–50 customers to be worth doing. If your honest expectation is 5–10 friends-of-friends, Model B is the wrong shape and Model A is the answer.

---

## 3. Phasing

### Phase 0 — Validate (4–6 weeks, ~€500–2,500)

Prove someone will pay before building compliance apparatus.

- Genericise the runbook: remove Pepephone/Canary-specific content, parameterise phone number, region, model choice
- Build the install automation (target: config file in, working instance out — see gate below)
- Draft a lightweight services agreement + NDA for Model A engagements (lawyer, ~€500–1,500)
- Find 3 pilot customers. Charge them. Even €200 — the point is a real transaction, not revenue
- **Gate:** 3 paying pilots completed, and at least one *asked* about ongoing management

Do not proceed to Phase 1 without clearing that gate.

### Phase 1 — Legal foundation (4–8 weeks, ~€3,000–7,000)

Only if Phase 0 gate cleared and you're moving toward Model B.

- Engage Spanish data protection counsel
- Determine DPO requirement (Art. 37 — see [02](02-gdpr-obligations.md) §7)
- Draft DPA, ToS, privacy notice
- Cyber liability + professional indemnity insurance in place **before first Model B customer**
- Company structure review with your gestor (personal liability exposure for handling privileged data)
- **Gate:** signed DPA template, insurance bound, counsel comfortable with the model

### Phase 2 — Technical remediation (6–10 weeks engineering)

The work in [03](03-security-architecture.md). Runs partly in parallel with Phase 1.

- Secrets out of your head and into a vault
- Audit logging of all administrative access
- Break-glass procedure with customer notification
- Per-customer isolation review
- Automated provisioning and de-provisioning (including verified data deletion)
- **Gate:** you can answer "what did you access, when, and why?" with evidence, for any customer instance

### Phase 3 — ISMS documentation (6–10 weeks, faster given your ISO background)

- ROPA, DPIA, TOMs, incident response plan, access control policy, sub-processor register
- Risk assessment and treatment plan
- **Gate:** documentation set complete and internally consistent

### Phase 4 — Certification (6–12 months, €10,000–25,000) — optional

Only when a customer or insurer actually demands it. See [06](06-certification-path.md). Do not do this speculatively.

---

## 4. Critical path and dependencies

```
Phase 0 (validate) ──┬──> Phase 1 (legal) ──┬──> First Model B customer
                     │                       │
                     └──> Phase 2 (technical)┘
                                             │
                                Phase 3 (ISMS docs)
                                             │
                                Phase 4 (certification, on demand)
```

**Hard dependency:** insurance must be bound and the DPA signed before the first Model B customer's data touches your infrastructure. Not "before launch" — before the first byte.

**Soft dependency:** Phase 2 and Phase 3 inform each other. Write the TOMs document (Phase 3) as you build the controls (Phase 2), not after — retrofitting documentation to existing systems is where ISO projects usually bog down, as you'll know.

---

## 5. Kill criteria

Worth agreeing with yourself now, while it's cheap to walk away:

- **Phase 0 fails to produce 3 paying pilots in 8 weeks** → the market isn't there at this price. Stop.
- **Counsel advises a DPO is mandatory** → adds €3,000–8,000/year recurring. Re-run the unit economics before continuing; may push you permanently to Model A.
- **Install automation can't get under ~90 minutes of your attended time** → per-customer labour cost kills both models. The Signal captcha step (see [03](03-security-architecture.md) §6) is the known hard constraint here.
- **First real customer demands ISO 27001 before signing** → you've found the market's actual entry price. Either commit to Phase 4 properly or target less regulated customers.

---

## 6. What "automated in 30 minutes" realistically looks like

Your stated target. Assessment of feasibility, component by component:

| Component | Automatable? | Notes |
|---|---|---|
| Hetzner provisioning | **Yes** — fully | Terraform or `hcloud` CLI. Server, volume, firewall, cloud-init |
| Base OS config, Docker, signal-cli, Java | **Yes** — already is | Existing cloud-init from runbook step 3a |
| LUKS setup | **Partly** | Passphrase generation can be automated; *custody* is the policy question, not a technical one |
| Hermes install + config | **Yes** | Config templating + the wizard's non-interactive equivalents; needs testing |
| SearXNG | **Yes** | docker-compose, already scripted |
| systemd units | **Yes** | Already templated in runbook step 9 |
| **Signal registration** | **No — hard blocker** | Captcha is human-solved *by design*, specifically to prevent automated account creation. See below |
| Customer onboarding, key handover | **No** | Deliberately human |

**The Signal captcha is the binding constraint on your 30-minute target.** It is anti-automation by design and will not yield to better scripting. Three options:

1. **Accept it** — one human step, ~5–10 minutes, in an otherwise automated flow. 30 minutes total stays plausible.
2. **Pre-register a pool of numbers** in batches during dedicated sessions, then assign at provisioning time. Turns per-customer latency into batched work. Check Signal's ToS on this — pre-registering accounts for later transfer to third parties may not be permitted, and getting this wrong risks account bans. **Verify before relying on it.**
3. **Switch platform** to WhatsApp Business Cloud API, which is designed for programmatic provisioning. Changes the product, adds Meta as a party — likely a poor fit for privacy-motivated customers, but it is the honest automation-friendly answer.

Realistic target: **20–40 minutes attended time**, most of it the captcha and handover. That meets your goal.
