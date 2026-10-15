# Hermes Build — Accounts & Services Summary

*Quick-reference companion to `hermes-build-runbook.md`. For setup steps and commands, see that file.*

---

## Accounts you created

| Service | What it's for | Credential | Monthly cost |
|---|---|---|---|
| **Hetzner Cloud** | Hosts the server (`hermes-01`, CX22, Nuremberg/Falkenstein) and the encrypted volume (grown from 10 GB to 50 GB on 2026-10-02) | Account login (2FA recommended, not covered above) | ~€4.49 server + ~€2.20 volume (50 GB) + ~€0.70 IPv4 ≈ **€7.40/mo** |
| **Pepephone** | Prepaid Spanish SIM, `+34*******22` — used only to receive the one-time SMS during Signal registration for the bot account | Physical SIM, kept in a phone (never touches the server) | Prepaid — varies by plan; needs periodic top-up or the line lapses (see runbook step 5) |
| **Fireworks AI** | Hosts GLM-5.2, the model Hermes actually talks to for every response | API key `hermes-ted`, spend limit set; each additional user (`user2`, `user3`) gets their own key with its own spend limit, in their profile's `.env` | Pay-per-token — live catalog pricing showed **$1.40 in / $4.40 out per 1M tokens** for GLM-5.2; expect single-digit dollars/month at personal-use volume |
| **Signal** | The bot's own account, `+34*******22`, profile name "Toaster On Wheels" — this is a registration via `signal-cli`, not a signup with a password | Registration Lock PIN (24–32 char generated passphrase) | Free |

## Credentials — SSH keypair

Not a third-party account, but the access mechanism for everything above: an `ed25519` SSH keypair used to reach the Hetzner server. No password login is enabled (key-only, hardened in step 3a).

## Self-hosted — no external account

| Service | What it's for | Where it runs |
|---|---|---|
| **SearXNG** | Web search backend — your own metasearch instance, so search queries don't go to a third party | Docker container on `hermes-01`, `127.0.0.1:8888` |
| **Podman (rootless)** | Runs each Hermes profile's terminal, file and code tools in its own container (added 2026-10-02) | On `hermes-01` as `h-ted`; images and containers stored on the encrypted volume |
| **agent-browser / Browser Use** | Local browser automation, drives a headless Chromium on the box itself | Runs locally, no cloud provider configured |

## Secrets — confirm these are all in your password manager

- LUKS passphrase (unlocks `/mnt/hermes` after every reboot — no recovery if lost)
- Signal Registration Lock PIN for `+34*******22`
- Fireworks API keys — yours (`hermes-ted`) and one per additional user
- OpenRouter API keys — one per profile
- SSH private key (or your usual SSH key management)

## Considered, deliberately not used

Worth recording so it's clear these were evaluated, not overlooked:

- **Nous Portal** — Hermes' own managed subscription option (covers model access + browser automation with no separate keys). Skipped in favor of Fireworks directly, for jurisdiction and cost reasons.
- **OpenRouter** (as primary provider) — skipped as a steady-state model provider; it's an extra hop between you and the model.
- **Firecrawl** — optional web-extraction service, free tier available. Left unconfigured; Browser Use covers page-reading well enough for now.
- **A third-party "RTK" token-savings plugin** — investigated and rejected. Multiple near-duplicate, low-trust GitHub repos offering to intercept and rewrite shell commands before execution — too privileged a position on a box holding real secrets, for an unverified one-star project.
- **Discord, Telegram, WhatsApp, and the other 15+ messaging platforms Hermes supports** — Signal only, by design.
- **Group messaging on Signal** — left disabled; the platform has no @-mention gating yet, so it would mean the bot responding to every message in any group it's added to.

## OpenRouter — now in use (2026-10-02)

OpenRouter keys are set up on purpose for `default`, `user2` and `user3` (each in its own profile `.env`). Background helper tasks are using the paid `google/gemini-2.5-flash-lite` model through it.

## Earlier open item — vision (OpenRouter now set up; confirm by sending the bot a photo)

- **Vision auxiliary model.** GLM-5.2 isn't vision-capable, and Fireworks has no vision-capable chat model to fall back on, so images sent to the bot over Signal currently aren't analyzed. The fix (documented in the runbook, step 7) is a narrowly-scoped **OpenRouter** account + API key, used *only* for this one auxiliary slot — not as a general provider. Requires signing up for OpenRouter when you're ready to prioritize it.

## Rolling total

Roughly **€7.40/month infrastructure + single-digit dollars/month in Fireworks tokens + Pepephone's prepaid cost** — well under a single Claude Pro seat, per the original cost comparison that shaped this build.
