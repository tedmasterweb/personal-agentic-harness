#!/usr/bin/env bash
# add-hermes-user.sh — add a new person to the shared Hermes Signal bot.
#
# Usage (as h-ted, NOT root):
#   ./add-hermes-user.sh <profile-name> <+phone-number> [--dry-run]
#   e.g. ./add-hermes-user.sh maria +34600111222
#
# What it does (same steps as the runbook, "Phase 2" + "Containers for every profile"):
#   1. Checks the name and number, and that neither is already in use.
#   2. Backs up your ~/.hermes/config.yaml and ~/.hermes/.env.
#   3. Creates a BLANK profile (not --clone, which would copy your memory and skills).
#   4. Copies your config.yaml into it, minus your Signal connection block
#      (platforms:) and the gateway: block (routing belongs only to you).
#   5. Asks you to paste the person's own Fireworks key (and optionally an
#      OpenRouter key) — typed keys are not shown and not saved in shell history.
#   6. Puts the profile's tools in its own Podman container, with its own
#      ~/projects/<name> folder and the next free block of 10 ports.
#   7. Adds the number to YOUR SIGNAL_ALLOWED_USERS and adds the routing rule
#      (number -> profile) to YOUR config.
#   8. Restarts the gateway once and checks the profile is served.
#
# --dry-run prints what would happen and changes nothing.
#
# Written 2026-10-02 for Hermes Agent v0.21.5 (2026.9.24). Not yet run on the
# real server — try --dry-run first.

set -euo pipefail

IMAGE="docker.io/nikolaik/python-nodejs:python3.11-nodejs20"   # full name: Podman refuses short names
CONTAINER_CPU=1
CONTAINER_MEMORY=1536      # MB
HERMES_HOME_DIR="${HOME}/.hermes"
PROJECTS_ROOT="${HOME}/projects"

die()  { echo "ERROR: $*" >&2; exit 1; }
info() { echo "==> $*"; }

# ---------- arguments ----------
DRY_RUN=0
ARGS=()
for a in "$@"; do
  case "$a" in
    --dry-run) DRY_RUN=1 ;;
    -h|--help) sed -n '2,25p' "$0"; exit 0 ;;
    *) ARGS+=("$a") ;;
  esac
done
[ "${#ARGS[@]}" -eq 2 ] || die "usage: $0 <profile-name> <+phone-number> [--dry-run]"
NAME="${ARGS[0]}"
PHONE="${ARGS[1]}"

run() {  # run a command, or just print it in dry-run mode
  if [ "$DRY_RUN" -eq 1 ]; then echo "   [dry-run] $*"; else "$@"; fi
}

# ---------- checks ----------
[ "$(id -u)" -ne 0 ] || die "run this as h-ted, not root"
command -v hermes  >/dev/null || die "'hermes' not found on PATH"
command -v podman  >/dev/null || die "'podman' not found — install it first (runbook: Installing rootless Podman)"
command -v python3 >/dev/null || die "'python3' not found"

[[ "$NAME" =~ ^[a-z][a-z0-9-]{1,30}$ ]] \
  || die "profile name must be lowercase letters, numbers and hyphens, starting with a letter (got '$NAME')"
case "$NAME" in default|main) die "'$NAME' is reserved" ;; esac
[[ "$PHONE" =~ ^\+[1-9][0-9]{6,14}$ ]] \
  || die "phone number must be in +<country><number> form with no spaces, e.g. +34600111222 (got '$PHONE')"

CONFIG="${HERMES_HOME_DIR}/config.yaml"
ENVFILE="${HERMES_HOME_DIR}/.env"
PROFILE_DIR="${HERMES_HOME_DIR}/profiles/${NAME}"
[ -f "$CONFIG" ]  || die "$CONFIG not found"
[ -f "$ENVFILE" ] || die "$ENVFILE not found"
[ ! -e "$PROFILE_DIR" ] || die "profile folder $PROFILE_DIR already exists"

grep -q '^HERMES_DOCKER_BINARY=' "$ENVFILE" \
  || die "HERMES_DOCKER_BINARY is not set in your .env — run: hermes config set HERMES_DOCKER_BINARY /usr/bin/podman"
grep -q '^SIGNAL_ALLOWED_USERS=' "$ENVFILE" \
  || die "SIGNAL_ALLOWED_USERS line not found in $ENVFILE"

if grep -E '^SIGNAL_ALLOWED_USERS=' "$ENVFILE" | tr -d "\"' " | cut -d= -f2- | tr ',' '\n' | grep -qxF "$PHONE"; then
  die "$PHONE is already in SIGNAL_ALLOWED_USERS — is this person already set up?"
fi

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Existing routes (as JSON) from YOUR config. Empty / unset -> [].
ROUTES_JSON="$(hermes config get gateway.profile_routes --json 2>/dev/null || true)"
ROUTES_JSON="$(python3 - "$ROUTES_JSON" <<'PY'
import json, sys
raw = sys.argv[1].strip()
try:
    val = json.loads(raw) if raw else []
except json.JSONDecodeError:
    sys.exit("could not read gateway.profile_routes from 'hermes config get --json' output:\n" + raw)
if isinstance(val, dict) and "value" in val:   # tolerate a {"key":..,"value":..} wrapper
    val = val["value"]
print(json.dumps(val or []))
PY
)" || die "could not read the existing routing rules"

python3 - "$ROUTES_JSON" "$NAME" "$PHONE" <<'PY' || exit 1
import json, sys
routes, name, phone = json.loads(sys.argv[1]), sys.argv[2], sys.argv[3]
if not isinstance(routes, list):
    sys.exit("ERROR: gateway.profile_routes is not a list — fix it by hand first")
for r in routes:
    if str(r.get("profile")) == name:
        sys.exit(f"ERROR: a routing rule for profile '{name}' already exists")
    if str(r.get("chat_id")) == phone:
        sys.exit(f"ERROR: a routing rule for {phone} already exists (profile '{r.get('profile')}')")
PY

if grep -qE '^profile_routes:' "$CONFIG"; then
  die "your config has profile_routes at the top level, not under gateway: — move it under gateway: first"
fi

# Next free port block: highest '--publish=N-' start in any profile config, + 100.
LAST_START="$(grep -hoE -- '--publish=[0-9]+-' "$CONFIG" "${HERMES_HOME_DIR}"/profiles/*/config.yaml 2>/dev/null \
              | grep -oE '[0-9]+' | sort -n | tail -1 || true)"
PORT_START=$(( ${LAST_START:-3000} + 100 ))
PORT_END=$(( PORT_START + 9 ))
[ "$PORT_END" -lt 65536 ] || die "no free port block left"
if ss -ltn 2>/dev/null | awk '{print $4}' | grep -qE ":(${PORT_START}|$((PORT_START+1))|$((PORT_START+2))|$((PORT_START+3))|$((PORT_START+4))|$((PORT_START+5))|$((PORT_START+6))|$((PORT_START+7))|$((PORT_START+8))|${PORT_END})\$"; then
  die "something on the server is already using a port in ${PORT_START}-${PORT_END}"
fi

if ! podman image exists "$IMAGE" 2>/dev/null; then
  echo "NOTE: the container image isn't downloaded yet. The person's first command will wait for a ~1 GB download."
  echo "      To avoid that, run first:  podman pull $IMAGE"
fi

echo
echo "About to add:"
echo "  profile:        $NAME   (folder $PROFILE_DIR)"
echo "  Signal number:  $PHONE"
echo "  projects:       ${PROJECTS_ROOT}/${NAME}  ->  /workspace/projects in their container"
echo "  ports:          ${PORT_START}-${PORT_END}"
[ "$DRY_RUN" -eq 1 ] && echo "  (dry run — nothing will be changed)"
echo

# ---------- keys (asked before any change, so a mistake here leaves nothing half-done) ----------
FW_KEY=""; OR_KEY=""
if [ "$DRY_RUN" -eq 0 ]; then
  read -r -p "Continue? [y/N] " ok
  [[ "$ok" =~ ^[Yy]$ ]] || die "cancelled — nothing was changed"
  read -r -s -p "Paste ${NAME}'s Fireworks API key (input hidden): " FW_KEY; echo
  [ -n "$FW_KEY" ] || die "a Fireworks key is required — nothing was changed"
  read -r -s -p "Paste ${NAME}'s OpenRouter API key, or press Enter to skip (no image reading without it): " OR_KEY; echo
fi

# ---------- backups ----------
TS="$(date +%Y%m%d-%H%M%S)"
info "Backing up your config.yaml and .env (suffix .bak-${TS})"
run cp -p "$CONFIG"  "${CONFIG}.bak-${TS}"
run cp -p "$ENVFILE" "${ENVFILE}.bak-${TS}"

# ---------- profile ----------
info "Creating blank profile '$NAME'"
run hermes profile create "$NAME"

info "Copying your config.yaml without the platforms: and gateway: blocks"
if [ "$DRY_RUN" -eq 0 ]; then
  python3 - "$CONFIG" "${PROFILE_DIR}/config.yaml" <<'PY'
import re, sys
src, dst = sys.argv[1], sys.argv[2]
# Top-level keys that must NOT be copied: your Signal connection, and routing/multiplexing (yours only).
drop = {"platforms", "gateway", "multiplex_profiles", "profile_routes"}
out, skipping = [], False
for line in open(src, encoding="utf-8").read().splitlines(keepends=True):
    if skipping:
        # still inside the dropped block: indented lines and blank lines
        if line.strip() == "" or line[0] in " \t":
            continue
        skipping = False
    m = re.match(r"^([A-Za-z_][\w-]*)\s*:", line)
    if m and m.group(1) in drop:
        skipping = True
        continue
    out.append(line)
text = "".join(out)
for k in drop:
    if re.search(rf"^{k}\s*:", text, re.M):
        sys.exit(f"ERROR: '{k}:' still present after stripping — stopping")
open(dst, "w", encoding="utf-8").write(text)
PY
  chmod 600 "${PROFILE_DIR}/config.yaml"
else
  echo "   [dry-run] write ${PROFILE_DIR}/config.yaml (your config minus platforms:/gateway:)"
fi

info "Writing the profile's own .env (its keys only; no SIGNAL_* lines)"
if [ "$DRY_RUN" -eq 0 ]; then
  SEARX_LINE="$(grep -E '^SEARXNG_URL=' "$ENVFILE" || echo 'SEARXNG_URL=http://127.0.0.1:8888')"
  umask 077
  {
    echo "# Created by add-hermes-user.sh on ${TS}"
    echo "FIREWORKS_API_KEY=${FW_KEY}"
    [ -n "$OR_KEY" ] && echo "OPENROUTER_API_KEY=${OR_KEY}"
    echo "$SEARX_LINE"
  } > "${PROFILE_DIR}/.env"
  chmod 600 "${PROFILE_DIR}/.env"
  unset FW_KEY OR_KEY
else
  echo "   [dry-run] write ${PROFILE_DIR}/.env with FIREWORKS_API_KEY, OPENROUTER_API_KEY (if given), SEARXNG_URL"
fi

info "Container settings for '$NAME'"
run mkdir -p "${PROJECTS_ROOT}/${NAME}"
run hermes -p "$NAME" config set terminal.backend docker
run hermes -p "$NAME" config set terminal.docker_image "$IMAGE"
run hermes -p "$NAME" config set terminal.container_persistent true
run hermes -p "$NAME" config set terminal.container_cpu "$CONTAINER_CPU"
run hermes -p "$NAME" config set terminal.container_memory "$CONTAINER_MEMORY"
run hermes -p "$NAME" config set terminal.docker_volumes "[\"${PROJECTS_ROOT}/${NAME}:/workspace/projects\"]"
run hermes -p "$NAME" config set terminal.docker_extra_args "[\"--publish=${PORT_START}-${PORT_END}:${PORT_START}-${PORT_END}\"]"

# ---------- your profile: allowlist + route ----------
info "Adding $PHONE to your SIGNAL_ALLOWED_USERS"
if [ "$DRY_RUN" -eq 0 ]; then
  python3 - "$ENVFILE" "$PHONE" <<'PY'
import sys
path, phone = sys.argv[1], sys.argv[2]
lines = open(path, encoding="utf-8").read().splitlines(keepends=True)
done = False
for i, line in enumerate(lines):
    if line.startswith("SIGNAL_ALLOWED_USERS=") and not done:
        val = line.split("=", 1)[1].strip().strip("\"'")
        nums = [n.strip() for n in val.split(",") if n.strip()]
        if phone not in nums:
            nums.append(phone)
        lines[i] = "SIGNAL_ALLOWED_USERS=" + ",".join(nums) + "\n"
        done = True
if not done:
    sys.exit("ERROR: SIGNAL_ALLOWED_USERS line disappeared")
open(path, "w", encoding="utf-8").write("".join(lines))
PY
else
  echo "   [dry-run] append ,$PHONE to SIGNAL_ALLOWED_USERS in $ENVFILE"
fi

info "Adding the routing rule ${NAME}-signal (${PHONE} -> ${NAME}) to your config"
NEW_ROUTES="$(python3 - "$ROUTES_JSON" "$NAME" "$PHONE" <<'PY'
import json, sys
routes, name, phone = json.loads(sys.argv[1]), sys.argv[2], sys.argv[3]
routes.append({"name": f"{name}-signal", "platform": "signal", "chat_id": phone, "profile": name})
print(json.dumps(routes))
PY
)"
run hermes config set gateway.multiplex_profiles true
run hermes config set gateway.profile_routes "$NEW_ROUTES"

# ---------- restart + check ----------
info "Restarting the gateway (all profiles reconnect)"
run hermes gateway restart
if [ "$DRY_RUN" -eq 0 ]; then
  sleep 10
  hermes -p "$NAME" gateway status || true
fi

if [ "$DRY_RUN" -eq 1 ]; then echo; echo "Dry run finished — nothing was changed."; exit 0; fi

cat <<EOF

Done.

Next:
  1. Check the line above says the profile is served by the default-profile multiplexer.
  2. Ask ${NAME} to message the bot. Their agent should answer (not yours).
  3. Ask them to send: Run \`whoami\` and \`ls /workspace/projects\` in the terminal.
     Expect 'root' (container-only) and an empty folder.
  4. Their apps can use ports ${PORT_START}-${PORT_END}. They are only reachable from
     outside if the Hetzner firewall allows them — and then by anyone, with no password.

Undo (if needed): restore ${CONFIG}.bak-${TS} and ${ENVFILE}.bak-${TS},
then: hermes profile delete ${NAME} ; hermes gateway restart
EOF
