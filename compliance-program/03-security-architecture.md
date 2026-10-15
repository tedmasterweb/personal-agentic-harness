# 03 — Security Architecture Remediation

*What has to change technically between the working personal build and something sellable to a regulated professional.*

---

## 1. The central problem, stated plainly

In the personal build, the disclosure to your family was: *"I hold root on this box, so I can read your conversations. The isolation protects you from each other, not from me."*

Under Model B, that same sentence, addressed to a therapist, reads: *"I can read your clients' session notes, and there is no technical or audited control preventing me from doing so."*

That is not fixable with a paragraph in the terms. It needs three things:

1. **Technical reduction** of what you can access without the customer knowing
2. **Audit evidence** of what you actually accessed and when
3. **Contractual commitment** about when access is permitted (covered in [04](04-customer-documents.md))

Also worth naming honestly in your marketing: you can reduce and evidence your access, but on a VM you administer, a determined administrator with root retains theoretical access to running memory. **Do not claim zero-knowledge or "we cannot see your data."** Claim what's true: least privilege, logged access, contractual limits, and rapid detection. Overclaiming here is both a misrepresentation risk and, with technical customers, a credibility risk.

---

## 2. Control roadmap

| # | Control | Current state | Target state | Priority |
|---|---|---|---|---|
| C1 | LUKS passphrase custody | You generate and hold it | Customer-held with escrow option; you cannot unlock unilaterally without triggering evidence | **Critical** |
| C2 | Administrative access logging | None | All SSH sessions logged, shipped off-box, tamper-evident | **Critical** |
| C3 | Secrets management | In your head / password manager | Dedicated secrets vault, per-customer scoping, rotation | **Critical** |
| C4 | Break-glass procedure | Undefined | Documented, customer-notified, time-boxed | **Critical** |
| C5 | Backups | None (accepted risk personally) | Encrypted, tested restore, defined RPO/RTO | **High** |
| C6 | Data export / erasure tooling | None | Per-data-subject export and verified erasure | **High** |
| C7 | Per-customer isolation | Same-box Unix users (from multi-user design) | **One VM per customer** | **High** |
| C8 | Provisioning automation | Manual runbook | Scripted, idempotent, logged | **High** |
| C9 | De-provisioning | Manual | Scripted, with deletion certificate | Medium |
| C10 | Vulnerability management | Ad hoc | Defined patch cadence, monitored advisories | Medium |
| C11 | Monitoring / alerting | None | Uptime + security event alerting | Medium |
| C12 | Prompt injection containment | Terminal access enabled | Reviewed per customer; consider restricted toolset | Medium |

---

## 3. C1 — LUKS passphrase custody (the crux)

Four options, with honest trade-offs:

**Option 1 — Customer holds it, you never have it.**
Strongest position. The customer runs `hermes-unlock` after any reboot. Kills the low-touch managed model — every reboot needs them. Realistically unworkable for a non-technical therapist unless reboots are rare and scheduled.

**Option 2 — Customer holds it, you hold a sealed escrow copy.**
Escrow in a vault requiring a break-glass procedure (C4) that emits an alert to the customer. You *can* recover, but never silently. **This is the recommended default.** It preserves supportability while making access evident.

**Option 3 — You hold it, access is logged.**
Operationally easiest, weakest story. Acceptable only for non-regulated customers.

**Option 4 — Auto-unlock via TPM/network-bound encryption (Clevis/Tang).**
Removes the manual step but means the box unlocks itself, so encryption-at-rest protects only against physical disk theft — which, on a Hetzner VM, was never the realistic threat anyway. **Worth saying out loud: full-disk encryption on a cloud VM is largely a compliance and hygiene control, not a defence against the hypervisor operator.** Don't let it carry more weight in your security story than it deserves.

**Recommendation: Option 2**, with Option 1 offered to customers who want maximum assurance and can handle it.

---

## 4. C2 — Audit logging

Without this you cannot detect a breach (Art. 33), cannot prove you didn't access something, and cannot answer a customer's reasonable "have you been in my system?" question.

Minimum implementation:

- **Session recording** for administrative access — `auditd` for command-level, or a bastion/jump host that records sessions
- **Ship logs off-box immediately** — logs stored only on the box you administer prove nothing. Central collector, append-only, on infrastructure with separate credentials
- **Log at minimum:** authentication events, `sudo`/privilege escalation, LUKS unlock events, service start/stop, file access within customer data directories, secrets vault access
- **Alert on:** any interactive login to a customer instance, any break-glass escrow access, any failed authentication burst

**Effort:** 5–10 days. Options range from a simple rsyslog-to-central-host setup through to a managed SIEM; at your scale, self-hosted (e.g. Loki or Wazuh) is proportionate — but note that a self-hosted log collector you also administer weakens the tamper-evidence argument slightly. A managed logging service with separate credentials is the stronger story if budget allows.

---

## 5. C3 — Secrets management

Currently: LUKS passphrase, Signal Registration Lock PIN, Fireworks key, SSH keys — in your password manager and your head. That does not scale past a handful of customers and gives you no rotation, no scoping, no access audit.

Target:

- Dedicated secrets manager (Bitwarden Secrets Manager, HashiCorp Vault, Infisical — all viable at this scale)
- **Per-customer scoping** so a single credential compromise doesn't cascade
- **Access logging** on the vault itself, feeding C2
- Defined **rotation policy** — at minimum on customer offboarding and on any suspected compromise
- **Per-customer Fireworks API keys** (you're already doing this in the multi-user design) with individual spend caps

**Effort:** 4–8 days including migration of existing secrets.

---

## 6. C7 — One VM per customer

The multi-user design in `hermes-multi-user-build.md` uses Unix users plus iptables owner-matching on a shared box. That was the right call for a family, where everyone already trusts the root holder.

**For unrelated customers, it is not.** Shared-kernel isolation between mutually-untrusted regulated professionals is a much harder position to defend to an auditor, and a container escape or kernel vulnerability becomes a multi-customer breach. It also creates messy questions about co-mingled backups, logs, and sub-processor records.

**Use one Hetzner VM per customer.** At €4.49/month the cost difference is immaterial next to the risk reduction, and it makes de-provisioning trivially verifiable — you destroy the whole server and the volume, and can say so with a straight face.

This does mean the elaborate iptables/Unix-user isolation work becomes unnecessary under Model B. Keep it documented for the family deployment; don't carry it into the product.

---

## 7. C12 — Prompt injection, honestly assessed

The personal build gives the agent terminal access, and the agent reads untrusted web content via SearXNG and Browser Use. That combination means a malicious web page can potentially steer the agent into running commands — a risk already acknowledged in the multi-user design's residual risks.

For a customer holding privileged data, this is a materially bigger deal than it is for you personally. Options:

- **Restricted toolset per customer** — disable `terminal`, `execute_code`, and file operations for customers who only want a conversational assistant. Costs them cron and automation; most therapists will not care. **This is likely the right default for the regulated segment.**
- **Sandboxed terminal backend** — Hermes supports Docker, Modal, Daytona, Vercel Sandbox backends. Moves execution off the host holding the data
- **Document it** in the DPIA either way — an auditor asking "what happens if the agent reads a malicious page?" deserves a real answer

Note the interaction with Browser Use mode: it is only offered to sessions that *also* have terminal access. Disabling terminal for regulated customers means falling back to the built-in browser tools — slightly higher token cost, meaningfully smaller blast radius. That's a good trade for this segment.

---

## 8. What you can honestly claim, once this is done

Useful to draft now, because it disciplines the engineering:

> Customer data is encrypted at rest and in transit. Each customer runs on dedicated, isolated infrastructure in Germany. Our administrative access requires a documented break-glass procedure that notifies you, and every administrative session is logged to append-only storage we cannot silently alter. We do not use your data to train models, and our inference provider operates a zero-retention policy for the models we use. We are a data processor under GDPR and operate under a signed DPA with Standard Contractual Clauses covering our US sub-processor.

Every sentence there is falsifiable and, after Phase 2, true. That is a much stronger sales position than "it's self-hosted so it's private" — and it survives contact with a customer who actually knows what to ask.
