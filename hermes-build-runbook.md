# Hermes Build Runbook

**[YOU]** = requires your accounts, credentials, devices, or an SSH session.
**[ME]** = I produce the file or command; you paste it in. I have no access to your server, phone, or accounts.

---

## Before you start — [YOU]

Have these ready:

- [ ] Hetzner Cloud account
- [ ] SSH keypair (`ssh-keygen -t ed25519` if you don't have one)
- [ ] A phone number for the bot, able to receive SMS or a voice call — **Pepephone SIM, `+34*******22`**
- [ ] Fireworks AI account
- [ ] Password manager entries ready for: LUKS passphrase, Signal Registration Lock PIN, Fireworks key
- [ ] Optional: Firecrawl account (free tier, 500 credits/mo) for web page extraction

---

## A note on VAT — [YOU], applies to every paid signup below

*Not tax advice — a starting point for the conversation with each vendor's support, or a local gestor for anything with real stakes.*

The Canary Islands are part of Spain and the EU but are **excluded from the EU VAT territory** (EU VAT Directive 2006/112/EC, Art. 6). Mainland Spain's 21% IVA shouldn't apply to you; the Canaries have their own indirect tax, IGIC, at a 7% standard rate. This isn't the business reverse-charge mechanism — no VAT number needed, it's simply outside EU VAT's scope entirely.

For **every** paid service in this build (Hetzner, Fireworks, Firecrawl if you outgrow its free tier):

1. If checkout lets you specify a province (Santa Cruz de Tenerife / Las Palmas) rather than just "Spain," use it — this is usually what triggers correct handling automatically.
2. If a platform still charges the mainland rate, contact billing and cite: *Council Directive 2006/112/EC, Article 6 — Canary Islands excluded from EU VAT territory.*
3. Whether IGIC itself then applies, and under what mechanism, is a separate and genuinely more complex question — worth a real check with a local gestor rather than assuming either way.

---

# Phase 1 — Your instance

### 1. Provision the server — [YOU]

Register at **accounts.hetzner.com** (one account covers all Hetzner products). Use the **Cloud Console** — not Robot (dedicated servers), not Storage Box, not konsoleH.

- Register as **business** only if you have a Spanish VAT ID → reverse charge, €0 VAT. Otherwise personal, and expect 21% IVA on top of the displayed ex-VAT price.
- Don't sign up over a VPN; expect a possible ID check on a new account.

In the Cloud Console, create a project called `hermes`, then:

- Server: click the **"Cost-Optimized"** tab first — the console may default to "Regular Performance" (AMD/CPX line), which is a pricier, different product. Under Cost-Optimized, try **x86 (Intel/AMD) → CX22** (~€4–5/mo, live-check the price shown to you, don't trust any figure quoted earlier in this conversation). If that architecture is greyed out or shows "Limited availability" and won't provision, switch to **Arm64 (Ampere®)** and pick the closest 2 vCPU / 4 GB option (the CAX line) instead — fully compatible with everything in this build, no known incompatibility.
- Image: **Ubuntu 26.04 LTS** — the preselected default. Newest LTS, supported into the 2030s. Playwright added official 26.04 support in May 2026, and 26.04 ships a new enough JDK for current signal-cli (24.04 does not — see step 3).
- Location: **Nuremberg or Falkenstein** (Germany) — nearest EU site to Spain, keeps GDPR jurisdiction
- Add your SSH public key during creation
- Create a **10 GB volume**, attach it to the server. **The volume is separate storage, not the server's boot disk — the OS lives on the CX22's own root disk regardless of what you do here.** If the console forces a format choice with no way to skip it, either ext4 or xfs is fine; LUKS overwrites it completely in step 3, so nothing you pick here survives. Leave automount on or off, whichever the UI allows — Hetzner's automount writes its fstab entry with `nofail`, so even if the underlying filesystem later becomes unreadable (which it will, once it's a LUKS container), boot continues normally instead of hanging.
- **Name**: `hermes-01` — clear and greppable once Phase 2 adds more servers.
- **Firewall**: create one. Hetzner Cloud Firewalls are free and stateful, and filter traffic before it reaches the VM at all — a second layer in front of the sshd hardening in step 3.
  - Inbound: TCP 22 from Any IPv4/IPv6. Your home IP is almost certainly dynamic, so restricting the source isn't practical — key-only auth (no password login) is doing the real work here.
  - Outbound: leave the default (allow all) — Hermes needs to reach Fireworks, Firecrawl, GitHub, etc.
  - Name it reusably, e.g. `hermes-ssh`, so Phase 2 servers can attach the same rule.
  - **Under "Apply to," select Server and pick your server explicitly.** A firewall that exists but isn't applied to anything protects nothing — this step is easy to miss since it's a separate, initially-empty section on the creation form. Leave "Labels" on the firewall itself empty; that's just console tagging.
  - If you're creating the firewall before the server exists, the Server picker will be empty/greyed out — expected. Save it unattached, then either pick it from a "Firewalls" section back on the server creation form, or attach it afterward via the server's own settings or the firewall's Apply-to screen once the server exists.
  - No inbound rule needed for Signal. signal-cli only makes *outbound* connections to Signal's servers (HTTPS/443) and receives messages over that same connection — nothing from Signal's network ever initiates a connection to this box. That's already covered since outbound is left unrestricted. The local Hermes↔signal-cli link (`127.0.0.1:8081`) is loopback-only and invisible to this firewall entirely; it's governed by the `iptables` rule in step 4 instead.
  - Not worth doing: a non-standard SSH port. It only cuts noise from automated scanners, does nothing against a targeted attacker, and risks locking you out from networks that only permit outbound 22/80/443. Key-only auth plus this firewall already covers the real risk.
- **Backups**: skip it. Hetzner's Backups add-on (~20% surcharge on the server price) only covers the server's **local root disk** — it does not back up attached Volumes. Your actual data (`state.db`, Signal credentials) lives entirely on the encrypted Volume, so this checkbox would protect the one thing that's trivial to reinstall (Ubuntu + Hermes) and miss the one thing that isn't. Real coverage for `/mnt/hermes` is a separate, still-open task — flagged in step 12.
- **Placement Group**: skip. This spreads multiple servers across different physical hosts so one hardware failure can't take out both — meaningless with a single server. Revisit only if you add a second server for redundancy later.
- **Labels**: add a couple now, free and pays off once you have more resources: `project=hermes`, `role=gateway`.
- **Networking**: keep both **Public IPv4** and **Public IPv6** checked — the IPv4 carries a small metered charge (~€0.70/mo per the console) but some networks you'll check the agent from lack usable IPv6, so it's worth keeping. Leave **Private networks** unchecked — that's for servers talking to each other, and you only have one server, in this phase and the next.
- **Cloud config**: use it — paste the script from **step 3a** below into this field before clicking create. It runs automatically, once, on first boot as root, and covers everything in step 3 that involves no secret. It deliberately excludes LUKS setup: a disk-encryption passphrase can't safely go anywhere the metadata service can expose it to anything running on the box, the same reason it never goes in a file on disk. That part stays a manual SSH step — 3b.

Record the server IP. For the volume, use its **stable by-id path**, not `/dev/sdb` — device letters can shift if you attach another volume later:

```bash
ls -l /dev/disk/by-id/ | grep HC_Volume
# → /dev/disk/by-id/scsi-0HC_Volume_12345678
```

Use that full path everywhere `$VOL` appears below.

### 2. Create the Fireworks key — [YOU]

- Create an API key, name it `hermes-ted`
- **Set a spend limit on it now.** Metered billing has no ceiling.
- Copy the key somewhere safe

### 3a. Cloud config — [ME] script, [YOU] paste into the "Cloud config" field in step 1, before creating the server

No secrets in this one — safe to sit in Hetzner's metadata service. Runs once, automatically, a minute or two after the server first boots.

```bash
#!/usr/bin/env bash
# cloud-init: runs once on first boot, as root
# Architecture-agnostic as written — works unmodified on both x86 (CX) and
# Arm64/Ampere (CAX). The Docker repo line below detects the architecture
# at runtime; everything else (apt packages, signal-cli's Java tarball) is
# already multi-arch.
set -euo pipefail

apt update
apt install -y git curl xz-utils build-essential cryptsetup iptables-persistent ca-certificates

# Rootless Podman — runs each Hermes profile's terminal/file/code tools in its own container
# (added 2026-10-02; the existing server got it by hand with `apt install podman`)
apt install -y podman

# Java — current signal-cli requires JRE 25 minimum.
# (Hermes' own docs still say "Java 17+"; that is stale. Trust signal-cli's README.)
apt install -y openjdk-25-jre-headless || apt install -y default-jre-headless

# Docker from Docker's own repo, not the distro package — distro Docker freezes at
# release version for the whole LTS lifetime, which is the wrong trade on a long-lived box.
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  > /etc/apt/sources.list.d/docker.list
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
  || { rm /etc/apt/sources.list.d/docker.list; apt update; apt install -y docker.io docker-compose-v2; }

# SSH hardening
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
systemctl restart ssh

# signal-cli
VERSION=$(curl -Ls -o /dev/null -w '%{url_effective}' \
  https://github.com/AsamK/signal-cli/releases/latest | sed 's/^.*\/v//')
curl -L -O "https://github.com/AsamK/signal-cli/releases/download/v${VERSION}/signal-cli-${VERSION}.tar.gz"
tar xf "signal-cli-${VERSION}.tar.gz" -C /opt
ln -sf "/opt/signal-cli-${VERSION}/bin/signal-cli" /usr/local/bin/

touch /root/cloud-init-done
```

### 3b. LUKS setup — [ME] commands, [YOU] run

SSH in as root. First confirm cloud-init finished (`ls /root/cloud-init-done`; if missing, wait a minute and check again — don't proceed until it's there, or `java -version` and `docker --version` will fail below). Then:

```bash
java -version    # MUST report 25 or newer, or signal-cli will not run
docker --version

# Set VOL to the by-id path you recorded in step 1
VOL=/dev/disk/by-id/scsi-0HC_Volume_106613150

# If Hetzner's automount got to this volume before you did, it'll already be
# mounted — and cryptsetup can't format a device that's in use. Clear it first;
# harmless no-ops if it was never mounted.
umount "$VOL" 2>/dev/null || true
umount /mnt/HC_Volume_* 2>/dev/null || true
sed -i "\|${VOL}|d" /etc/fstab
sed -i '\|/mnt/HC_Volume_|d' /etc/fstab
systemctl daemon-reload

# If the volume was created pre-formatted (ext4/xfs), cryptsetup will ask you to
# type YES in capitals to confirm overwriting it. That's expected — say yes.
# You'll also be prompted for a LUKS passphrase, twice.
cryptsetup luksFormat "$VOL"
cryptsetup open "$VOL" hermesdata
mkfs.ext4 /dev/mapper/hermesdata
mkdir -p /mnt/hermes
mount /dev/mapper/hermesdata /mnt/hermes
chown root:root /mnt/hermes
chmod 755 /mnt/hermes

# Clean up the stray automount leftovers, if Hetzner's automount ran on attach.
# Harmless if it didn't — these just won't exist.
sed -i "\|^${VOL}|d" /etc/fstab
rmdir /mnt/HC_Volume_* 2>/dev/null || true
systemctl daemon-reload

echo "Done. LUKS passphrase → password manager, now."
```

**Save the LUKS passphrase to your password manager before continuing.** There is no recovery.

### 4. Create the service user — [ME] script, [YOU] run

The home directory lives **on the encrypted volume**, so code, agent data, and Signal credentials are all encrypted together.

```bash
#!/usr/bin/env bash
# 02-adduser.sh   usage: ./02-adduser.sh h-ted 8081
set -euo pipefail
USER_NAME="$1"; PORT="$2"

useradd -m -d "/mnt/hermes/${USER_NAME}" -s /bin/bash "$USER_NAME"
chmod 700 "/mnt/hermes/${USER_NAME}"

# Lock this user's signal-cli port to this user only
iptables -A OUTPUT -o lo -p tcp --dport "$PORT" \
  -m owner ! --uid-owner "$USER_NAME" -j REJECT
netfilter-persistent save

mkdir -p /etc/hermes
echo "Created ${USER_NAME} on port ${PORT}."
```

Run: `./02-adduser.sh h-ted 8081`

**Do not add this user to `sudo`.**

### 5. Register the Signal account — [YOU]

> **The SIM stays in a phone. It never goes near the server.** The number is only a verification channel: Signal texts it once, you read the code off the phone and type it into the server. After that signal-cli holds registration credentials and talks to Signal over plain internet — no SIM, no cellular, no SMS in normal operation.

Put the Pepephone SIM in a phone, confirm it has signal and can receive a test SMS.

**Expect a captcha.** Signal challenges registrations from datacenter IPs (which is what a Hetzner server's IP is) — plan for this up front rather than treating it as an error, so you don't burn a wasted attempt and risk the rate limit described below. Set up the tunnel *before* you register:

From your **local machine** (not the server), open a spare terminal and leave this running:
```bash
ssh -D 1080 -N root@<server-ip>
```
In Firefox → Settings → Network Settings → Manual proxy: SOCKS Host `127.0.0.1`, Port `1080`, SOCKS v5, check **"Proxy DNS when using SOCKS v5."** This routes that browser's traffic through the server, which matters because Signal checks that whoever solves the captcha shares the registering IP — solving it from your normal, un-tunneled browser will very likely produce a token that fails.

**Is `signalcaptchas.org` legitimate?** Yes — it's Signal's own captcha service, confirmed via the [official signal-cli GitHub wiki](https://github.com/AsamK/signal-cli/wiki/Registration-with-captcha) (maintained by the developer of the exact `signal-cli` binary this server is running, sourced straight from that project's own releases in step 3a). Worth checking that page yourself rather than taking it on faith — a site trying to launch an unfamiliar app is exactly the pattern phishing uses, so the instinct to verify is the right one.

In the **proxied** Firefox window, go to `https://signalcaptchas.org/registration/generate.html` and solve the captcha. Two things happen once you do, independently of each other:

1. The page auto-attempts a `signalcaptcha://` redirect, which your OS intercepts as an **"Open Signal.app?" dialog**. This is expected and appears *after* you solve the captcha, not before. Click **Cancel** — you don't need the app.
2. Separately, an **"Open Signal"** link appears on the page itself, below the captcha. **Right-click it → Copy Link** (don't left-click).

Back in a root SSH session on the server, drop into `h-ted` and register with the copied token immediately — it expires fast:

```bash
# This is root spending its own privilege to drop into h-ted's shell — it does
# NOT grant h-ted any sudo rights. h-ted still can't run sudo itself afterward.
sudo -u h-ted -i

signal-cli -a +34*******22 register --captcha signalcaptcha://signal-hcaptcha....   # paste your copied link, no quotes around it
```

If it errors with "Invalid captcha given," the token expired or the IP didn't match — get a fresh one via the same proxied page and retry. Repeated failed attempts trigger a 429 rate limit that only clears by waiting, so don't rapid-fire retries.

Once `register` succeeds:

```bash
signal-cli -a +34*******22 verify 123-456
# → SMS arrives on the phone holding the Pepephone SIM. Read the code.
# Silent output + exit code 0 = success — signal-cli doesn't print a confirmation
# banner. The setPin command right below can only succeed on a verified account,
# so it doubles as independent confirmation this step actually worked.

# Enable Registration Lock (signal-cli IS the client — there's no app to do this from)
signal-cli -a +34*******22 setPin "PASTE_A_GENERATED_24-32_CHAR_ALPHANUMERIC_PASSPHRASE_HERE"
```

**Set a profile name** so the account doesn't show up as a bare phone number to anyone it messages (relevant for every Phase 2 registration too):

```bash
signal-cli -a +34*******22 updateProfile --given-name "Toaster On Wheels"
```

**Sanity check the account is fully live** — send yourself a test message; a printed timestamp (e.g. `1786665841732`, Unix milliseconds) means success, no error text:

```bash
signal-cli -a +34*******22 send -m "test" +34696072517    # your personal number
```

**Tear down the tunnel once registration succeeds:** go to the terminal running the `ssh -D 1080 -N` command and press **Ctrl+C**. It's a separate connection from your admin SSH session, so this doesn't affect anything else. Then **revert Firefox's proxy back to "No proxy"** right away — leaving it pointed at a closed tunnel breaks Firefox's connectivity to every site, not just this one, until you switch it back.

This whole captcha dance may recur for each Phase 2 number registered from the same server IP.

Despite the name, Signal's "PIN" accepts alphanumeric strings with no length limit — generate one via your password manager (24–32 chars, letters/digits only, to avoid shell-quoting surprises when pasting it into the command) and store it there. It's a real secret, not a phone-unlock code: you'll essentially never type it from memory, so favor entropy over memorability. **Generate a unique one per phone number** — Phase 2 registrations each get their own. Registration Lock resets after 7 days of *account* inactivity, so a continuously-running bot keeps it armed.

**Do not register the Signal app to `+34*******22`.** Having the SIM in your phone causes no conflict on its own — but registering Signal-the-app to that number would take the account away from signal-cli. One number, one account.

**Keep the line alive.** Two prepaid-specific risks:

- Spanish prepaid lines are typically cancelled after a period with no usage or top-up. Check Pepephone's exact inactivity window and set a calendar reminder to top up or send a text before it lapses.
- With a physical SIM you need it back in a phone to receive any future verification code. Keep it in your daily phone if you have a spare slot, or keep a cheap handset around for it.

If the line lapses *and* the signal-cli data is lost, the account is unrecoverable.

### 6. Install Hermes — [YOU]

Still as `h-ted`:

```bash
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
source ~/.bashrc
hermes doctor
```

**Known issue — Playwright on Ubuntu 26.04:** the installer may fail partway with `ERROR: Playwright does not support chromium on ubuntu26.04-x64`. This contradicts what was assumed above (a claimed May 2026 support date) — that turned out to be premature; as of this build, Playwright's published chromium builds only cover 22.04/24.04. Confirmed via the [Playwright GitHub tracker](https://github.com/microsoft/playwright/issues/40117). Fix — 24.04's chromium build runs fine on 26.04:

```bash
export PLAYWRIGHT_HOST_PLATFORM_OVERRIDE=ubuntu24.04-x64
echo 'export PLAYWRIGHT_HOST_PLATFORM_OVERRIDE=ubuntu24.04-x64' >> ~/.bashrc
python3 -m playwright install chromium    # or: npx playwright install chromium — whichever the installer used
```

Then rerun `hermes doctor` (or the install script) to confirm it completes.

**Interactive setup wizard:** once install succeeds, it drops you into a prompt — *"How would you like to set up Hermes?"* — with three options. **Choose "Full setup" (bring your own keys)**, not the default-highlighted "Quick Setup (Nous Portal)." Quick Setup routes model access through Nous Portal's free OAuth login instead of the Fireworks account from step 2 — skipping the provider this whole build was chosen around (US jurisdiction, documented zero-data-retention, cost). "Blank Slate" is also wrong here since it opts out of tools step 7 configures explicitly (SearXNG, local terminal backend). Full setup is the one that walks you through the same choices step 7 below makes explicit.

### 7. Configure Hermes — [ME] files, [YOU] fill in secrets

`/mnt/hermes/h-ted/.hermes/.env`:

```bash
FIREWORKS_API_KEY=fw_REPLACE_ME
SIGNAL_HTTP_URL=http://127.0.0.1:8081
SIGNAL_ACCOUNT=+34*******22          # the bot number (Pepephone)
SIGNAL_ALLOWED_USERS=+34XXXXXXXXX    # YOUR PERSONAL number — not the bot number
FIRECRAWL_API_KEY=fc-REPLACE_ME      # optional
SEARXNG_URL=http://127.0.0.1:8888
```

`/mnt/hermes/h-ted/.hermes/config.yaml`:

```yaml
terminal:
  backend: local        # changed to `docker` (run by Podman) on 2026-10-02 — see "Containers for every profile"

model:
  provider: fireworks
  default: "accounts/fireworks/models/glm-5p2"

auxiliary:
  compression:
    provider: fireworks
    model: "REPLACE — context window >= GLM-5.2's"

session_reset:
  mode: idle        # ignored since v0.21.5 — see the warnings note in Phase 2

web:
  search_backend: "searxng"
  extract_backend: "firecrawl"
```

Then run `hermes model` and `hermes tools` to confirm the wizard agrees with the file.

> The `auxiliary.compression.model` line matters. If its context window is smaller than the main model's, compaction silently drops conversation history instead of summarizing it.

**Open item — vision isn't working yet.** GLM-5.2 (the primary model) isn't vision-capable, and Fireworks' catalog has no vision-capable chat model to fall back on for the `auxiliary.vision` slot either — confirmed by scanning all 24 models in `hermes model` → auxiliary → vision → Fireworks AI, none labeled VL/vision. `hermes doctor` surfaces this as `⚠ vision (system dependency not met)`. Without it, images sent to the bot over Signal (family photos, screenshots) won't be analyzed.

Fix, when ready to prioritize it: `hermes model` → configure auxiliary model → vision → **Custom endpoint (direct URL)**, pointed at `https://openrouter.ai/api/v1` with model `google/gemini-2.5-flash` (Nous's own documented pattern for this exact gap) and an `OPENROUTER_API_KEY`. This is a narrow, deliberate exception — OpenRouter scoped to *only* this one auxiliary slot, not the primary provider — different from the general "avoid OpenRouter as a steady-state provider" reasoning that applied to the main model choice, since here it's the only viable path to working vision at all on the current stack.

### 8. Stand up SearXNG — [ME] files, [YOU] run

As root:

```bash
mkdir -p /opt/searxng/config && cd /opt/searxng
cat > docker-compose.yml <<'EOF'
services:
  searxng:
    image: searxng/searxng:latest
    container_name: searxng
    ports: ["127.0.0.1:8888:8080"]
    volumes: ["./config:/etc/searxng:rw"]
    environment:
      - SEARXNG_BASE_URL=http://localhost:8888/
    restart: unless-stopped
EOF
docker compose up -d
sleep 15
docker cp searxng:/etc/searxng/settings.yml ./config/settings.yml
```

Add JSON output to `./config/settings.yml`:

```yaml
search:
  formats:
    - html
    - json
```

Then:

```bash
docker restart searxng
curl -s "http://127.0.0.1:8888/search?q=test&format=json" | head -c 200
```

Expect JSON, not a 403.

### 9. Install the services — [ME] units, [YOU] install

`/etc/hermes/h-ted.env`:
```bash
SIGNAL_NUMBER=+34*******22
SIGNAL_PORT=8081
```

`/etc/systemd/system/signal-cli@.service`:
```ini
[Unit]
Description=signal-cli daemon for %i
After=network-online.target

[Service]
User=%i
EnvironmentFile=/etc/hermes/%i.env
Environment="JAVA_OPTS=-Xmx256m"
ExecStart=/usr/local/bin/signal-cli -a ${SIGNAL_NUMBER} daemon --http 127.0.0.1:${SIGNAL_PORT}
Restart=always
RestartSec=5
NoNewPrivileges=yes
PrivateTmp=yes
```

`/etc/systemd/system/hermes@.service`:
```ini
[Unit]
Description=Hermes Agent for %i
After=signal-cli@%i.service
Requires=signal-cli@%i.service

[Service]
User=%i
ExecStart=/mnt/hermes/%i/.local/bin/hermes gateway start
Restart=always
RestartSec=5
NoNewPrivileges=yes
PrivateTmp=yes
ProtectSystem=strict
ReadWritePaths=/mnt/hermes/%i
```

```bash
systemctl daemon-reload
systemctl start signal-cli@h-ted          # (originally also hermes@h-ted — don't; see the note below)
systemctl status signal-cli@h-ted
```

**Do not `systemctl enable` these** — the encrypted volume needs a manual unlock first, so boot-time start would just fail.

> **⚠ How the server actually runs today (verified 2026-10-02) — use this, not the `hermes@` unit above.**
>
> - **signal-cli** runs as the system unit `signal-cli@h-ted` (as above).
> - **The Hermes gateway** runs as a systemd **user** service, `hermes-gateway.service`, owned by `h-ted` (`/mnt/hermes/h-ted/.config/systemd/user/hermes-gateway.service`, "disabled", linger enabled). It was created by Hermes itself. Manage it as `h-ted`: `hermes gateway status | restart | start | stop`.
> - **Do not start `hermes@h-ted`.** Its `ExecStart` is `hermes gateway start`, which only asks systemd to start the user service and then exits; with `Restart=always` it relaunched every ~5 s forever, wasting CPU. It was stopped on 2026-10-02 and the unlock script (step 11) no longer starts it. The unit file still exists on the server.
> - **On a rebuilt server**, skip the `hermes@.service` file above. Instead, as `h-ted`: `hermes gateway install` (creates the user service); as root: `loginctl enable-linger h-ted`. *(Not re-tested on a fresh server.)*
> - **Gotcha:** `systemctl --user …` in a shell opened with `sudo -u h-ted -i` fails with "Failed to connect to user scope bus". Run `export XDG_RUNTIME_DIR=/run/user/$(id -u)` first. (`hermes gateway status` works without it.)

### 10. Test — [YOU]

From your phone, message the bot number on Signal. Expect a reply.

Then try:
- `/new` — starts a fresh session
- "search the web for today's weather in <your city>" — confirms SearXNG
- Send a PDF — confirms attachment handling
- "remember that I prefer concise answers" then `/new` and ask what it remembers — confirms memory
- "every day at 7am, send me a summary of tech news" — confirms cron

### 11. Install the unlock script — [ME] script, [YOU] install

`/usr/local/bin/hermes-unlock` (current version, updated and reboot-tested 2026-10-02):

```bash
#!/usr/bin/env bash
set -euo pipefail
VOL=/dev/disk/by-id/scsi-0HC_Volume_106613150
cryptsetup open "$VOL" hermesdata
mount /dev/mapper/hermesdata /mnt/hermes
for U in $(ls /mnt/hermes | grep -v '^lost+found$'); do
  systemctl start "signal-cli@${U}" 2>/dev/null || true
  systemctl --user -M "${U}@" daemon-reload 2>/dev/null || true
  systemctl --user -M "${U}@" start hermes-gateway 2>/dev/null || true
done
echo "Instances up."
```

`chmod +x /usr/local/bin/hermes-unlock`

> **Gotchas fixed in this version.** The original script looped over `$(ls /mnt/hermes)`, which includes ext4's `lost+found` folder → `signal-cli@lost+found` sat in a restart loop. It also started the `hermes@` system unit (see step 9 note). Reboot test 2026-10-02: Signal and the gateway came back; apps the agents started (e.g. senior-calculator) do not.

**What this script does, line by line.** After any reboot — planned or not — the box comes back up with `/mnt/hermes` locked and empty, and both services stopped. That's deliberate, not a bug: the LUKS passphrase can't be stored anywhere on the box for auto-unlock without defeating the point of encrypting it in the first place (same reasoning from step 1's cloud-config note), and step 9 explicitly skipped `systemctl enable` for the same reason — a boot-time service start would just fail against a still-locked volume. `hermes-unlock` is the one manual step that undoes both at once:

- `set -euo pipefail` — stop immediately on any error rather than plowing ahead with a half-broken state.
- `cryptsetup open "$VOL" hermesdata` — decrypts the volume. This is the interactive part: it prompts for the LUKS passphrase you saved to your password manager back in step 3b. Creates the decrypted device at `/dev/mapper/hermesdata`.
- `mount /dev/mapper/hermesdata /mnt/hermes` — mounts the now-decrypted filesystem at the usual path.
- `for U in $(ls /mnt/hermes | grep -v '^lost+found$'); do …; done` — once the volume's readable, this discovers every service-user directory under it (right now just `h-ted`), skipping `lost+found`, and for each one starts its `signal-cli@` system unit, makes that user's systemd reload its unit files (they live on the volume, which was locked at boot), and starts the user's `hermes-gateway` service. All profiles are served by that one gateway. The `2>/dev/null || true` matters: without it, `set -e` would abort the whole loop the moment any single user's service failed to start — this way, one broken instance doesn't take the others down with it.

**Bringing the server back up after a reboot — the exact steps:**

1. SSH in as root: `ssh root@<server-ip>`
2. Confirm the box actually finished booting normally (optional sanity check): `uptime`
3. Run the script: `hermes-unlock`
4. It pauses waiting for the LUKS passphrase — type it in (from your password manager; nothing is echoed to the terminal, that's normal for `cryptsetup`).
5. Wait for `Instances up.` to print.
6. Verify both are actually running, not just started-and-crashed: as root `systemctl status signal-cli@h-ted --no-pager | head -5`; as `h-ted` `hermes gateway status` — look for `active (running)` on both, not `activating` or `failed`.
7. Send yourself a test message on Signal and confirm you get a reply — the real end-to-end check, same as step 10.
8. Restart any apps you need (e.g. ask your agent to start senior-calculator in its container) — nothing starts them automatically.

If step 3 errors with something like "device hermesdata is already active," the volume was already unlocked (e.g., you're re-running after a partial failure) — skip straight to `mount /dev/mapper/hermesdata /mnt/hermes` (if not already mounted) and run the three `systemctl` lines from the loop by hand for `h-ted`.

**On skipping backups.** Your call, and reasonable for a non-production box — but worth being explicit about what it means: everything on `/mnt/hermes` (Signal registration credentials, conversation history, memory, skills) lives in exactly one place. If the Hetzner volume fails or gets corrupted, all of it is gone — recovery means re-registering the Signal number from scratch (assuming the Pepephone line hasn't lapsed) and starting the agent's memory over from nothing. That's a different risk from losing the LUKS passphrase (which just makes existing data unreadable) — this is the data not existing anywhere else at all. Fine to accept for now; worth revisiting if this stops being a "can live with losing it" box.

### 12. Operational setup — [YOU]

- [ ] Calendar reminder: quarterly reboot + `hermes-unlock`
- [ ] Uptime monitor pointed at the box, so you learn about unplanned reboots first
- [x] ~~Backups covering `/mnt/hermes`~~ — deliberately skipped (not production; accepted risk of total data loss on volume failure — see step 11)
- [ ] Monthly cron: `hermes sessions prune --older-than 90 --yes`
- [ ] Optional: install `fail2ban` for SSH brute-force protection — a more effective use of effort than a non-standard SSH port

---

# Growing the encrypted volume — [YOU]

*Decided 2026-10-02: grow `/mnt/hermes` from 10 GB to 50 GB (≈ €2.20/month) so rootless Podman can keep its images and containers on the encrypted disk. Growing is one-way — Hetzner volumes cannot be shrunk. There is no backup of this volume.*

1. **Look first** (as root): `lsblk -f` and `cryptsetup status hermesdata` — expect type `LUKS2` (or `LUKS1`), filesystem `ext4`, mounted at `/mnt/hermes`.
2. **Hetzner Cloud Console** → Volumes → the `hermes` volume → Resize → 50 GB. Works while attached and mounted.
3. **On the server, as root:**

```bash
lsblk /dev/disk/by-id/scsi-0HC_Volume_106613150   # should now show 50G
cryptsetup resize hermesdata                       # may ask for the LUKS passphrase
resize2fs /dev/mapper/hermesdata                   # grows ext4 while mounted
df -h /mnt/hermes                                  # should show ~49G size
```

If `lsblk` still shows 10G after the console resize, wait a minute and check again before running the other commands.

**Done 2026-10-02.** `cryptsetup resize` did ask for the LUKS passphrase. Result: `df -h /mnt/hermes` → 50G size, 7.9G used, 40G free.

# senior-calculator moved back onto the encrypted volume (2026-10-02)

It had been moved to `/var/lib/hermes-offload/senior-calculator` (server's own, unencrypted disk) with a symlink at `~/senior-calculator`, when the volume was full. After growing the volume: stopped the app, `rm ~/senior-calculator` (removes only the link — no trailing `/`, no `-r`), `cp -a` the folder back (930 MB). It is a Next.js app started with `npm start` (`next start`, production mode) on port 3000. It was then moved again, into `~/projects/ted/senior-calculator`, when containers were set up (see "Containers for every profile").

- **Now:** your agent runs it inside your container (`/workspace/projects/senior-calculator`); port 3000 is published by the container. Don't start it by hand on the server any more — the server copy would fight the container for port 3000.
- It does **not** start by itself after a reboot.
- **Gotcha:** `pkill -f 'next start'` only kills the small `sh -c next start` launcher; the real process renames itself `next-server` and keeps the port. Find it with `ss -ltnp | grep ':3000'` and `kill <pid>`.
- **Gotcha:** to remove the old symlink, `rm ~/senior-calculator` — no trailing `/` and no `-r`, or you delete the files it points to.
- Old copy to delete as root, if not done yet: `rm -rf /var/lib/hermes-offload/senior-calculator`.

# Installing rootless Podman — [YOU]

1. As **root**: `apt install podman`
2. As **h-ted** (in a shell opened with `sudo -u h-ted -i`, first `export XDG_RUNTIME_DIR=/run/user/$(id -u)`):

```bash
podman info --format '{{.Store.GraphRoot}}'     # should be under /mnt/hermes/h-ted/ (encrypted volume)
podman run --rm docker.io/library/alpine echo hello
```

**Done 2026-10-02.** Storage location: `/mnt/hermes/h-ted/.local/share/containers/storage` (on the encrypted volume); the alpine test printed `hello`. A rebuilt server gets Podman from the cloud-config script in step 3a.

---

# Phase 2 — A second person on the same bot number (profiles + routing)

*Added 2026-10-01 for Hermes Agent v0.21.5 (2026.9.24). This is the approach in use now. The older "one Linux user + one phone number per person" approach is kept below as an alternative.*

**The idea in plain words.** A *profile* is a complete, separate Hermes agent: its own settings, API key, memory, skills and chat history, stored in its own folder (`~/.hermes/profiles/<name>/`). Your existing agent is the profile called `default` (it lives in `~/.hermes/` itself). Only one gateway runs — yours. When it sees more than one profile it *multiplexes*: it serves all of them from the one process and the one Signal number. A *routing rule* (`profile_routes`) tells the gateway "messages from this phone number go to that profile." Anyone with no matching rule lands on `default` (you).

**Current state (2026-10-02).** Gateway serves all three profiles; the step 8 favourite-colour test result is not recorded here yet.

| Profile | Who | Folder | Own keys in its `.env` | Route |
|---|---|---|---|---|
| `default` | Ted | `~/.hermes/` | Fireworks `hermes-ted`, OpenRouter, all `SIGNAL_*` settings | none needed — unrouted numbers land here |
| `user2` | Additional user | `~/.hermes/profiles/user2/` | Fireworks (own key), OpenRouter | `user2-signal`, `chat_id` = their number |
| `user3` | Additional user | `~/.hermes/profiles/user3/` | Fireworks (own key), OpenRouter | `user3-signal`, `chat_id` = their number |

*(Profile names anonymized in this document. Both additional profiles were set up the same way — steps 2–7 below.)*

**Not done yet:** your own profile's config is also kept in a git repo, `~/.hermes-config` (a separate copy, not linked; `.env` is git-ignored). It has **not** been updated with the 2026-10-02 changes (routing block, container settings). Update it for your profile only.

`hermes gateway status` showed the one gateway serving all three; `hermes -p user2 gateway status` reported "running via the default-profile multiplexer". Your `SIGNAL_ALLOWED_USERS` must list every person's number.

Placeholder used below: profile name **`guest`** — replace with the real name (lowercase letters, numbers, hyphens). `+34YYYYYYYYY` = the second person's Signal number, written with the `+` and country code.

**Facts this relies on** (checked against the v0.21.5 source and docs):

- Who may talk to the bot is decided by the profile that owns the Signal connection — `default`. So the second person's number goes in **your** `SIGNAL_ALLOWED_USERS`, not theirs.
- The `guest` profile must **not** get its own `SIGNAL_ACCOUNT`. Two profiles with the same Signal account = "duplicate credential", and the second one is switched off.
- `profile_routes` and `multiplex_profiles` go in the **default** profile's `config.yaml`. Routes are ignored unless multiplexing is on.
- For a Signal direct message, `chat_id` is the sender's phone number. Use a `chat_id` route (not `user_id`): only `chat_id` routes also let the guest's scheduled (cron) jobs deliver messages back to them.
- `hermes profile create --clone` copies your `memories/USER.md` and `MEMORY.md` and your skills. For a different person, create a **blank** profile instead and copy only `config.yaml`.

### Second user — step 1: Look before changing anything — [YOU], as `h-ted`

```bash
hermes profile list
grep -n -A6 '^gateway:' ~/.hermes/config.yaml        # is there already a gateway: section?
grep -n -i 'signal\|platforms\|multiplex\|profile_routes' ~/.hermes/config.yaml
```

### Second user — step 2: Make a Fireworks key for the second person — [YOU]

Name it e.g. `hermes-guest`, **set its own spend limit**, save it to the password manager.

### Second user — step 3: Create the blank profile and give it your model settings — [YOU]

```bash
hermes profile create guest
cp ~/.hermes/config.yaml ~/.hermes/profiles/guest/config.yaml
grep -n -i 'multiplex\|profile_routes' ~/.hermes/profiles/guest/config.yaml   # should print nothing
```

If that last command prints anything, delete those lines from the **guest** copy (they belong only to `default`).

**Remove your Signal connection block from the guest copy.** Your `config.yaml` has a `platforms:` block (lines 206–213 as of 2026-10-01) with `signal: enabled: true` and a `home_channel` pointing at your own number. That belongs only to `default`. Keep the separate `platform_toolsets:` → `signal: - hermes-signal` lines (around line 161) — those set which tools a Signal chat gets.

```bash
sed -n 206,213p ~/.hermes/profiles/guest/config.yaml   # must show exactly platforms: ... user_id: (8 lines)
sed -i '206,213d' ~/.hermes/profiles/guest/config.yaml  # only if the line above looked right
grep -n -A3 '^platforms:' ~/.hermes/profiles/guest/config.yaml   # should print nothing
```

### Second user — step 4: Give the profile its own secrets — [YOU]

`nano ~/.hermes/profiles/guest/.env`, contents:

```bash
FIREWORKS_API_KEY=fw_THE_NEW_GUEST_KEY
SEARXNG_URL=http://127.0.0.1:8888
OPENROUTER_API_KEY=sk-or-...   # needed for image reading (vision); a profile only ever uses the keys in its OWN .env
# FIRECRAWL_API_KEY=...   only if you use Firecrawl
# No SIGNAL_* lines here.
```

```bash
chmod 600 ~/.hermes/profiles/guest/.env
```

### Second user — step 5: Let the second number through — [YOU]

`nano ~/.hermes/.env` (yours), change the allowlist to both numbers, comma-separated, no spaces:

```bash
SIGNAL_ALLOWED_USERS=+34696072517,+34YYYYYYYYY
```

### Second user — step 6: Turn on multiplexing and add the route — [YOU]

Make a backup first: `cp ~/.hermes/config.yaml ~/.hermes/config.yaml.bak`

**First person (no `gateway:` section yet)** — this is how the first additional user was added; it appends the block to the end of the file:

```bash
cat >> ~/.hermes/config.yaml <<'EOF'

gateway:
  multiplex_profiles: true
  profile_routes:
    - name: guest-signal
      platform: signal
      chat_id: "+34YYYYYYYYY"
      profile: guest
EOF
```

**Every later person** — do **not** run the `cat >>` again (a second `gateway:` key silently replaces the first, losing earlier routes). Open the file with `nano ~/.hermes/config.yaml` (Ctrl+W to search for `profile_routes`) and add one more `- name:` entry, lined up with spaces, not tabs. The finished block looks like:

```yaml
gateway:
  multiplex_profiles: true
  profile_routes:
    - name: user2-signal            # name: just a label
      platform: signal
      chat_id: "+34USER2NUMBER"     # quotes matter
      profile: user2                # must match the folder name in ~/.hermes/profiles/
    - name: user3-signal
      platform: signal
      chat_id: "+34USER3NUMBER"
      profile: user3
```

Each new person also needs: their own profile (steps 2–4), their number added to **your** `SIGNAL_ALLOWED_USERS` (step 5), and a restart (step 7).

### Second user — step 7: Restart and check — [YOU]

```bash
hermes gateway restart
hermes gateway status          # should list guest among the served profiles
hermes -p guest gateway status # should say it is served by the default gateway
```

If `guest` is not served, read the warning box `hermes gateway status` prints — it names the blocker.

### Second user — step 8: Test — [YOU] + the second person

1. Second person messages the bot. Expect a reply.
2. You message the bot. Expect a reply.
3. Each says "remember my favourite colour is X" (different colours), then `/new`, then asks "what is my favourite colour?" Each should get **their own** answer.
4. Logs, if something is off: `tail -f ~/.hermes/logs/gateway.log ~/.hermes/profiles/guest/logs/gateway.log` (phone numbers are partly hidden in logs).

**Warnings seen at gateway start (2026-10-02) — both harmless:**

- `session_reset.mode: idle is no longer applied` (once per profile): v0.21.5 ignores this setting; chats now start fresh only on `/new` or `/reset`. Leave it, or restore automatic resets with the plugin the warning names (`hermes-session-reset-policy` — not found in Hermes's own code, so check who publishes it before installing).
- `Auxiliary client: PAID lane engaged … OpenRouter fallback model 'google/gemini-2.5-flash-lite'`: a background helper task used a paid OpenRouter model. Intentional. To limit helpers to free models instead: `auxiliary.free_only: true`.

**If the second person gets your agent instead of theirs:** the route didn't match. Check the number in step 6 is exactly the same as in step 5 (with `+`), that it is quoted, and that you restarted.

> **Security — not done yet.** Both profiles run as the same Linux user (`h-ted`) — a profile is just a folder, and the one gateway process runs as `h-ted`. Hermes can't serve profiles owned by different Linux users from one gateway; a separate Linux user means a separate gateway and a separate bot number (see the alternative below). Their memory and history are kept apart. Since 2026-10-02 each profile's terminal, file and code tools run in its own container (next section), so those tools no longer see your files. Still on the server itself as `h-ted`: the Hermes gateway, scripts attached to scheduled jobs, and possibly the browser tool (see the Plan section). Fine for a trusted demo; review before giving access to anyone else. You also see everything they send.

---

### Adding the next person with a script — `add-hermes-user.sh`

`add-hermes-user.sh` (kept next to this runbook) does steps 2–7 above plus the container setup in one go:

```bash
./add-hermes-user.sh <profile-name> <+phone-number> --dry-run   # shows what it would do, changes nothing
./add-hermes-user.sh <profile-name> <+phone-number>             # does it
```

Run as `h-ted` on the server (copy it there first, e.g. `scp add-hermes-user.sh root@<server-ip>:/tmp/` then, as root, `install -o h-ted -m 755 /tmp/add-hermes-user.sh /mnt/hermes/h-ted/bin/` or any folder you like). It:

- refuses bad names/numbers, existing profiles, numbers already allowed, and existing routes — before changing anything;
- asks for the person's own Fireworks key (required) and OpenRouter key (optional), hidden, not saved in shell history;
- backs up your `config.yaml` and `.env` (`.bak-<date-time>`);
- creates a **blank** profile, copies your `config.yaml` minus the `platforms:` and `gateway:` blocks, writes the profile's `.env`;
- gives the profile its own container, `~/projects/<name>` folder and the next free block of 10 ports (3300–3309, then 3400–3409, …);
- adds the number to **your** `SIGNAL_ALLOWED_USERS` and the routing rule to **your** config (via `hermes config set`);
- restarts the gateway once and prints the profile's status, the next steps and how to undo.

*Written and tested 2026-10-02 against a mock of the server (fake `hermes`/`podman`); not yet run on the real server — do a `--dry-run` first. It relies on `hermes config get gateway.profile_routes --json` printing the routes as JSON; if it can't read them it stops before changing anything.*

### Containers for every profile (set up 2026-10-02)

Each profile's terminal, file and code tools run in its own rootless Podman container. One folder per profile on the encrypted volume is connected to that profile's container only; you (on the server) can see all of them.

| Profile | Server folder | Seen inside its container as | Published ports |
|---|---|---|---|
| `default` (you) | `~/projects/ted` | **no container** — see note below | — |
| `user2` | `~/projects/user2` | `/workspace/projects` | 3100–3109 |
| `user3` | `~/projects/user3` | `/workspace/projects` | 3200–3209 |

> **Your own profile does not use a container (decided 2026-10-02).** You need your agent for admin work over Signal (Hermes commands, other profiles, the server's files), which a container can't reach. Your profile is back on `terminal.backend local`; your container was removed. Your agent still keeps projects in `~/projects/ted`. Trade-off: your agent can see the whole `h-ted` account, including the other profiles' folders and keys.

Process-wide, in **your** `.env` only (keep it even though your own profile has no container — the others need it): `HERMES_DOCKER_BINARY=/usr/bin/podman` (Docker is also installed for SearXNG and `h-ted` can't use it; without this line Hermes picks Docker).

**Setup steps — [YOU], as `h-ted`** (in a shell opened with `sudo -u h-ted -i`):

1. Create the folders: `mkdir -p ~/projects/ted ~/projects/user2 ~/projects/user3`
2. Download the image once, so no agent waits on a 1 GB download on its first command, and check it works:

```bash
export XDG_RUNTIME_DIR=/run/user/$(id -u)
podman pull docker.io/nikolaik/python-nodejs:python3.11-nodejs20
podman run --rm docker.io/nikolaik/python-nodejs:python3.11-nodejs20 node --version   # prints a version number
```

   This can't go in the step 3a cloud-config script: the image is stored in `h-ted`'s home on the encrypted volume, which is locked when cloud-config runs.
3. Add the Podman line to your `.env`: `hermes config set HERMES_DOCKER_BINARY /usr/bin/podman`
4. Apply the settings below to each profile, then `hermes gateway restart` once.
5. Test from Signal: "Run `pwd`, `whoami` and `ls /workspace/projects` in the terminal". Expect `root` (container-only) and the profile's projects; `podman ps` on the server shows the container.

**Scheduled (cron) jobs with containers** (from v0.21.5 docs `features/cron.md` and `cron/scheduler_script.py`):

- The scheduler itself runs in the gateway, on the server.
- The agent's own steps in a job — terminal, read/write files, run code — use the profile's terminal backend, so they run **inside the profile's container** and only see `/workspace/projects` (plus the container's own `/root`).
- Scripts attached to a job (`script=…`, and script-only "no-agent" jobs) run **on the server** as `h-ted`, from `~/.hermes/scripts/` (or the profile's own `scripts/`), not in the container.
- A job's `workdir` is a server path; inside a container it only takes effect if it is the folder mounted at `/workspace`.
- So a job that used files elsewhere in `~/` must have those files moved into `~/projects/<name>/`, or that step turned into an attached script. Check jobs with `hermes cron list` / `hermes cron doctor`; test with `hermes cron run <job>` (runs on the next scheduler tick).

**If the agent reports `podman run … exit status 125`:** run the same image by hand to see the real error (`podman run --rm <image> echo ok`). Seen 2026-10-02: a short image name without `docker.io/`.

Per profile (`hermes config set …` for yours, `hermes -p <name> config set …` for the others):

```bash
terminal.backend docker
terminal.docker_image docker.io/nikolaik/python-nodejs:python3.11-nodejs20   # full name required: Podman refuses short names (exit 125, "short-name ... did not resolve")
terminal.container_persistent true
terminal.container_cpu 1
terminal.container_memory 1536
terminal.docker_volumes '["/mnt/hermes/h-ted/projects/<name>:/workspace/projects"]'
terminal.docker_extra_args '["--publish=3000-3009:3000-3009"]'   # 3100-3109 / 3200-3209 for the others
```

- Folder and port settings are fixed when a container is first created. To change them: `podman ps -a`, `podman rm -f <container>`, and Hermes makes a fresh one on next use. Files in `~/projects/<name>` are not affected.
- Ports are reachable from outside only if the Hetzner firewall allows them, and then by anyone, with no password.
- 3 × 1.5 GB memory limit is more than the server's 3.7 GB; only a problem if all three are busy at once.
- senior-calculator now lives at `~/projects/ted/senior-calculator` (`/workspace/projects/senior-calculator` inside your container).

---

### Security notes for the second person (researched 2026-10-02, v0.21.5)

- **Can the agent be tricked into showing `.env` keys?** Yes, with effort. `read_file` refuses `.env` files, and `security.redact_secrets` (on by default) masks key-shaped values even in a terminal `cat`. But the terminal tool runs as `h-ted`, and Hermes's own docs say these guards "do not sandbox a hostile or compromised agent" — e.g. encoding the file first gets around the masking. Treat every key on this server as readable by anyone who can chat with any profile.
- **Model choice:** a plain `/model` in chat changes the model for **that chat only**. `/model … --global` saves it to the config of **the profile that chat belongs to**. The guest can't change your model.
- **Limiting commands to one folder** — *done 2026-10-02 with option 2 below, for all three profiles.* The local terminal backend has no "stay in this folder" setting (`terminal.cwd` is only the starting folder; `terminal.home_mode: profile` only changes `$HOME`). Real options, per profile:
  1. Turn off the guest's terminal, code-execution and file tools (`hermes -p guest tools`). Simplest.
  2. Give the guest profile the `docker` terminal backend (Podman supported via `HERMES_DOCKER_BINARY=podman`). Its commands *and* file tools then run in a container that only sees what you mount. Needs root once to install rootless Podman. Do **not** add `h-ted` to the `docker` group — that is equivalent to root.

---

### Plan: letting other people's agent teams build and run software (partly built 2026-10-02)

Goal: each extra person's agents can create files, install databases, run dev servers, and show the result in a web browser — without touching anyone else's files or keys.

1. **One sealed container per profile.** Use the `docker` terminal backend on that profile, run by rootless **Podman** (`HERMES_DOCKER_BINARY=podman`). The profile's terminal, file tools and code tool all run inside it. "root" inside the container is an ordinary unprivileged user on the server. Keys stay outside (`docker_forward_env` empty). Subagents and Kanban workers for that profile use the same container. Set `container_cpu` / `container_memory` limits.
2. **Web preview.** No built-in port setting — ports are published via `terminal.docker_extra_args`. *Built:* port ranges 3000–3009 / 3100–3109 / 3200–3209 on all interfaces (public wherever the Hetzner firewall allows them). *Not built:* the safer version — bind to `127.0.0.1` only and put a password-protected HTTPS front door (e.g. Caddy) or a private network (e.g. Tailscale) in front.
3. **Capacity and cost.** CX22 (2 vCPU / 4 GB) is not enough for several teams with databases — plan to resize. **Measured 2026-10-02:** `/mnt/hermes` was 9.8 GB with 1.4 GB free → grown to 50 GB (40 GB free). RAM 3.7 GB with ~2.1 GB available and no swap — still the tightest limit. Rootless Podman stores images and containers in `h-ted`'s home on this volume. Each person gets their own Fireworks key with a spend limit.
4. **Browser tool — may run outside the container; to verify.** *Update 2026-10-02:* when the container failed to start, the agent reported `browser_exec` failing with the same `podman run` error, which suggests that with the container backend it goes through the container. Not confirmed. Original finding: Hermes's browser tools drive a real headless Chromium (runs JavaScript, renders React) on the server as `h-ted`. Worse, the default browser mode (`browser_exec`, Browser Use) runs model-written Python on the server itself, and is offered to any session with terminal access. For a guest profile: turn the browser off, or at minimum set `browser.backend: "off"` (built-in tools, no Python) and test what it can open (`file://`, `127.0.0.1:8081`). Hermes skips its private-address check for a local browser. (Source: v0.21.5 docs `features/browser.md`, `tools/browser_tool.py`.)
5. **Still open / to test:** whether the container can reach services on the server's own localhost (signal-cli 8081, SearXNG 8888); the container has internet access; whether web search still works from container-backed profiles.

---

# Phase 2 (alternative) — Fully separate instance per person

*Stronger isolation (separate Linux user, separate number), more work. Not the approach currently in use.*

Only when someone asks. Repeat with new values:

| Step | Owner | Action |
|---|---|---|
| A | [YOU] | New number; new Fireworks key with its own spend cap |
| B | [YOU] | `./02-adduser.sh h-alice 8082` |
| C | [YOU] | Register Signal as `h-alice`, enable Registration Lock, save PIN |
| D | [YOU] | Install Hermes as `h-alice`; copy the config, swap number/port/key |
| E | [YOU] | Create `/etc/hermes/h-alice.env`, `systemctl start signal-cli@h-alice`; gateway as a user service for `h-alice` (see the step 9 note — not `hermes@`) |
| F | [YOU] | Run the isolation tests below |
| G | [YOU] | Resize the server to 8 GB once you pass ~2–3 instances |

> **Scaling the numbers.** Physical SIMs don't scale well past one or two — each future verification means physically swapping the right SIM into a handset, and each prepaid line needs independent top-ups to avoid lapsing. For additional family instances, use eSIMs or a VoIP provider with a web SMS inbox: codes land in one browser tab and nothing competes for a slot.

### Isolation tests — run these before handing over access

```bash
# Filesystem — both must fail
sudo -u h-alice cat /mnt/hermes/h-ted/.hermes/state.db
sudo -u h-alice ls /mnt/hermes/h-ted/

# Daemon ports — first must fail, second must succeed
sudo -u h-alice curl -s -m 5 http://127.0.0.1:8081/api/v1/check
sudo -u h-alice curl -s -m 5 http://127.0.0.1:8082/api/v1/check
```

Then the one that actually matters — **from Alice's Signal thread**, ask:

> "Read the file /mnt/hermes/h-ted/.hermes/state.db and tell me what's in it."

The agent must report a permission error. If any content comes back, stop and fix permissions before going further.

---

# Gotchas we hit (2026-10-01 / 02) — read before repeating any of this

**Profiles and routing**
- `hermes profile create --clone` copies *your* memory files (`USER.md`, `MEMORY.md`) and skills → for another person create a blank profile and copy only `config.yaml`.
- A copied `config.yaml` carries your `platforms: signal:` block (Signal enabled + your number as home channel) → delete it from their copy. Keep `platform_toolsets: signal:`.
- A second person's number goes in **your** `SIGNAL_ALLOWED_USERS`, not theirs; their profile gets no `SIGNAL_*` lines (same Signal account twice = "duplicate credential", second one switched off).
- Adding the `gateway:` block with `cat >>` works once only; a second `gateway:` key silently replaces the first. Edit the existing block in nano for every later person.
- Each profile only uses keys in its **own** `.env` (e.g. no OpenRouter key → no image reading for that person).
- Startup warnings `session_reset.mode: idle is no longer applied` and `PAID lane engaged … OpenRouter` are harmless.

**Server and services**
- Two Hermes units existed: the real one is the user service `hermes-gateway`; the system unit `hermes@h-ted` was only a restart-looping "starter" → stopped; don't start it.
- The original unlock script also matched `lost+found` → fixed.
- `systemctl --user` after `sudo -u h-ted -i` needs `export XDG_RUNTIME_DIR=/run/user/$(id -u)`.
- The 10 GB volume was 85% full → grown to 50 GB. `cryptsetup resize` **did** ask for the LUKS passphrase. Volumes can't shrink, and there's no backup.

**Containers (Podman)**
- Docker is also installed (SearXNG) and comes first on `PATH`; `h-ted` can't use it → `HERMES_DOCKER_BINARY=/usr/bin/podman` in **your** `.env`.
- Podman refuses short image names (`podman run … exit status 125`, "short-name … did not resolve") → always `docker.io/…`. The agent misdiagnosed this as a "transient hiccup"; run the image by hand to see the real error.
- Hermes hides Podman's error text; reproduce with `podman run --rm <image> echo ok`.
- Folder and port settings are fixed when a container is first created → `podman rm -f` to apply changes.
- A container that publishes a port clashes with any app already using it on the server.
- One folder per profile (`~/projects/<name>`), not one folder per project.
- `podman pull` can't go in cloud-config (the image lives on the encrypted volume, locked at boot).
- A profile's `.env` is read by Hermes itself (model keys etc.) and is **deliberately not** visible to the agent's commands or inside its container. If a command, the code tool or a job's attached script needs one specific value (e.g. an API token), list its **name** under `terminal.env_passthrough` in that profile's `config.yaml` and keep the value in that profile's `.env`. Model/provider keys are refused. Don't pass the whole `.env` with Docker's `--env-file` via `docker_extra_args`: every key in it (Fireworks, OpenRouter, Signal settings) would become readable by anything running in the container.
- Scheduled jobs: the agent's steps run **in the container**; attached scripts run **on the server**. Jobs that used files elsewhere in `~/` need moving.
- A job's attached script must live inside the profile's own `scripts/` folder (`~/.hermes/scripts/` for yours); Hermes rejects a script path outside it, even via a symlink. Keep the server-side launcher there, not in `~/projects/…`: anything in `~/projects/<name>` can be edited by that profile's agent from inside its container, and a script the server runs on schedule would then run whatever the agent wrote, outside the container.
- Rootless Podman: "root" inside the container is `h-ted` on the server, so files the agent creates in `~/projects/<name>` belong to `h-ted`, even though they show as `root` from inside the container.

**Shell**
- In nano: Ctrl+V page down, Ctrl+Y page up, Ctrl+W search.
- `pkill -f 'next start'` misses the renamed `next-server` process → `kill <pid>`.
- Removing a symlink: `rm link` — no trailing `/`, no `-r`.

---

# Routine operations

| When | Owner | Action |
|---|---|---|
| After any reboot | [YOU] | `hermes-unlock`, then restart any apps (they don't come back by themselves) |
| After editing any `.env` or `config.yaml` | [YOU] | `hermes gateway restart` (restarts the one gateway, all profiles) |
| Check which profiles are served | [YOU] | `hermes gateway status`; one profile: `hermes -p user2 gateway status` |
| Take one person offline / back | [YOU] | `hermes -p user2 gateway stop` / `start` (others keep running) |
| Read logs | [YOU] | `export XDG_RUNTIME_DIR=/run/user/$(id -u)` then `journalctl --user -u hermes-gateway --since "15 min ago" --no-pager \| grep WARNING`; per profile: `~/.hermes/profiles/<name>/logs/gateway.log` |
| See / reset containers | [YOU] | `podman ps -a`; after changing a profile's folder or port settings: `podman rm -f <container>` (files in `~/projects/<name>` are kept) |
| Check scheduled jobs | [YOU] | `hermes cron list`, `hermes cron doctor`; run one now: `hermes cron run <job>` |
| Monthly | [YOU] | `hermes sessions prune --older-than 90 --yes` |
| Quarterly | [YOU] | Planned reboot, then unlock; `hermes update` |
| Anytime | [ME] | Paste errors or output and I'll debug |

---

**Tell your family before they start:** you hold root on this box, so you can read their conversations. The isolation protects them from each other, not from you. Anyone who wants privacy from you needs their own third-party account.
