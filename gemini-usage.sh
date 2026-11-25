#!/usr/bin/env bash
# <xbar.title>Gemini Usage Barometer</xbar.title>
# <xbar.version>v0.10.2</xbar.version>
# <xbar.author>Takayuki Miyano / Atlas Associates Inc.</xbar.author>
# <xbar.author.github>taka-avantgarde</xbar.author.github>
# <xbar.desc>Shows Gemini usage limits for Antigravity in the macOS menu bar.</xbar.desc>
# <xbar.dependencies>bash,curl,python3</xbar.dependencies>
# <xbar.abouturl>https://github.com/taka-avantgarde/ai-usage-barometer</xbar.abouturl>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideLastUpdated>true</swiftbar.hideLastUpdated>

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
set -u

VERSION="0.10.2"
WARN="${WARN:-70}"
DANGER="${DANGER:-90}"
OK_COLOR="${OK_COLOR:-#158F6A}"
WARN_COLOR="${WARN_COLOR:-#5E7B3A}"
DANGER_COLOR="${DANGER_COLOR:-#8C3B5A}"
MUTED_COLOR="${MUTED_COLOR:-#808080}"
FILL="${FILL:-█}"
EMPTY="${EMPTY:-░}"
MBAR_W="${MBAR_W:-5}"
DROP_W="${DROP_W:-10}"
DEFAULT_INTERVAL="${DEFAULT_INTERVAL:-180}"

CACHE_DIR="${XDG_CACHE_HOME:-${HOME:-/tmp}/.cache}/gemini-usage-barometer"
CACHE_FILE="$CACHE_DIR/usage.json"
INTERVAL_FILE="$CACHE_DIR/interval"
ERROR_FILE="$CACHE_DIR/last-error.txt"

mkdir -p "$CACHE_DIR" 2>/dev/null || true
chmod 700 "$CACHE_DIR" 2>/dev/null || true

FORCE_REFRESH=0
if [[ "${AIBAR_FORCE_REFRESH:-0}" == "1" || "${1:-}" == "--force" || "${2:-}" == "--force" ]]; then
  FORCE_REFRESH=1
fi

now_epoch() {
  date +%s
}

file_mtime() {
  local path="$1" value=""
  value="$(stat -f %m "$path" 2>/dev/null || true)"
  if [[ "$value" =~ ^[0-9]+$ ]]; then
    printf '%s\n' "$value"
    return 0
  fi
  value="$(stat -c %Y "$path" 2>/dev/null || true)"
  if [[ "$value" =~ ^[0-9]+$ ]]; then
    printf '%s\n' "$value"
  else
    printf '0\n'
  fi
}

case "${1:-}" in
  --set-interval)
    case "${2:-}" in
      [0-9]*)
        printf '%s\n' "$2" > "$INTERVAL_FILE" 2>/dev/null || true
        chmod 600 "$INTERVAL_FILE" 2>/dev/null || true
        ;;
    esac
    exit 0
    ;;
  --clear-cache)
    rm -f "$CACHE_FILE" "$ERROR_FILE" 2>/dev/null || true
    exit 0
    ;;
esac

clamp_percent() {
  awk -v n="${1:-0}" 'BEGIN { if (n < 0) n=0; if (n > 100) n=100; printf "%d", n+0.5 }'
}

color_for() {
  local used
  used="$(clamp_percent "$1")"
  if (( used >= DANGER )); then
    printf '%s' "$DANGER_COLOR"
  elif (( used >= WARN )); then
    printf '%s' "$WARN_COLOR"
  else
    printf '%s' "$OK_COLOR"
  fi
}

repeat_char() {
  local char="$1" count="$2" out="" i
  for ((i=0; i<count; i++)); do out+="$char"; done
  printf '%s' "$out"
}

usage_bar() {
  local used width remaining spent
  used="$(clamp_percent "$1")"
  width="$2"
  remaining=$(( ((100 - used) * width + 50) / 100 ))
  spent=$(( width - remaining ))
  printf '%s%s' "$(repeat_char "$FILL" "$remaining")" "$(repeat_char "$EMPTY" "$spent")"
}

format_reset() {
  local ts="${1:-}" now delta d h m
  if [[ -z "$ts" || "$ts" == "null" || "$ts" == "0" ]]; then
    printf ''
    return
  fi
  now="$(now_epoch)"
  delta=$(( ts - now ))
  if (( delta <= 0 )); then
    printf ''
    return
  fi
  d=$((delta / 86400))
  h=$(((delta % 86400) / 3600))
  m=$(((delta % 3600) / 60))
  if (( d > 0 )); then
    printf '%dd %dh' "$d" "$h"
  elif (( h > 0 )); then
    printf '%dh %02dm' "$h" "$m"
  else
    printf '%dm' "$m"
  fi
}

format_local_time() {
  local ts="${1:-}"
  if [[ -z "$ts" || "$ts" == "null" || "$ts" == "0" ]]; then
    printf '—'
    return
  fi
  date -r "$ts" '+%Y-%m-%d %H:%M' 2>/dev/null || date -d "@$ts" '+%Y-%m-%d %H:%M' 2>/dev/null || printf '—'
}

# Python extractor: reads test fixture, Antigravity 2.x daemon registry, legacy language_server, or SQLite state.vscdb
fetch_data() {
  GEMINI_CACHE_FILE="$CACHE_FILE" python3 - <<'PY'
import glob, os, sys, json, time, re, struct, sqlite3, subprocess, base64
from datetime import datetime, timezone

now = int(time.time())

def parse_iso_ts(reset_time):
    if isinstance(reset_time, (int, float)):
        return int(reset_time)
    if isinstance(reset_time, str) and reset_time:
        try:
            return int(datetime.fromisoformat(reset_time.replace("Z", "+00:00")).timestamp())
        except Exception:
            return 0
    return 0

# Helper to normalize models and quotas (used for GetUserStatus / state.vscdb / model-list fixtures)
def build_result(source, plan, models, fallback_secondary=None):
    gm_models = []
    for m in models:
        mid = (m.get("modelId") or m.get("id") or m.get("name") or "").lower()
        lbl = (m.get("label") or m.get("name") or "").lower()
        if any(k in mid or k in lbl for k in ("gemini", "orchestrator")) and not any(x in mid or x in lbl for x in ("claude", "gpt")):
            gm_models.append(m)
    if not gm_models:
        gm_models = models
    if not gm_models:
        return None

    parsed = []
    for m in gm_models:
        name = m.get("label") or m.get("name") or m.get("modelId") or "Gemini"
        q = m.get("quotaInfo") or {}
        rem_frac = q.get("remainingFraction")
        if rem_frac is None:
            rem_frac = m.get("remainingFraction", 1.0)
        rem_frac = float(rem_frac)
        reset_ts = parse_iso_ts(q.get("resetTime") or m.get("resetTime"))
        if reset_ts > 0 and reset_ts <= now:
            rem_frac = 1.0
            reset_ts = 0
        used_pct = max(0, min(100, int(round((1.0 - rem_frac) * 100))))
        parsed.append({
            "name": name,
            "used_pct": used_pct,
            "rem_frac": rem_frac,
            "reset_ts": reset_ts,
        })

    # Pick the most constrained (highest used_pct) active Gemini 5h bucket
    parsed.sort(key=lambda p: (p["used_pct"], p["reset_ts"]), reverse=True)
    p0 = parsed[0]
    primary = {
        "label": "5h",
        "used_percent": p0["used_pct"],
        "resets_at": p0["reset_ts"],
    }
    return {
        "source": source,
        "fetched_at": now,
        "plan": plan or "Google AI",
        "primary": primary,
        "secondary": fallback_secondary,
    }

def parse_quota_summary(qdata, plan="Google AI", source="live"):
    resp = qdata.get("response") or qdata
    groups = resp.get("groups") or []
    gm_group = next((g for g in groups if "gemini" in (g.get("displayName") or "").lower()), None)
    if not gm_group and groups:
        gm_group = groups[0]
    if not gm_group:
        return None
    buckets = gm_group.get("buckets") or []
    w5 = None
    w7 = None
    for b in buckets:
        bid = (b.get("bucketId") or "").lower()
        win = (b.get("window") or "").lower()
        rem = float(b.get("remainingFraction", 1.0))
        rts = parse_iso_ts(b.get("resetTime"))
        if rts > 0 and rts <= now:
            rem = 1.0
            rts = 0
        used_pct = max(0, min(100, int(round((1.0 - rem) * 100))))
        if "5h" in win or "5h" in bid:
            w5 = {"label": "5h", "used_percent": used_pct, "resets_at": rts}
        elif any(k in win or k in bid for k in ("week", "7d", "1w")):
            w7 = {"label": "1w", "used_percent": used_pct, "resets_at": rts}
    if not w5 and not w7:
        return None
    # ATLAS.md §1 invariant: even when 5h is unused (100% left), always emit 5h -> 1w
    if w7 and not w5:
        w5 = {"label": "5h", "used_percent": 0, "resets_at": 0}
    return {
        "source": source,
        "fetched_at": now,
        "plan": plan or "Google AI",
        "primary": w5,
        "secondary": w7,
    }

def parse_ustatus_obj(ustatus, source="fixture", fallback_secondary=None):
    plan = None
    tier = ustatus.get("userTier") or {}
    if tier.get("name"):
        plan = tier["name"]
    elif ustatus.get("plan"):
        plan = ustatus["plan"]
    configs = (ustatus.get("cascadeModelConfigData") or {}).get("clientModelConfigs") or []
    return build_result(source, plan, configs, fallback_secondary=fallback_secondary)

def load_cached_live():
    cfile = os.environ.get("GEMINI_CACHE_FILE") or ""
    if not cfile or not os.path.isfile(cfile):
        return None
    try:
        with open(cfile, "r", encoding="utf-8") as f:
            d = json.load(f)
        if isinstance(d, dict) and d.get("source") == "live":
            for k in ("primary", "secondary"):
                w = d.get(k)
                if isinstance(w, dict):
                    rts = int(w.get("resets_at") or 0)
                    if rts > 0 and rts <= now:
                        w["used_percent"] = 0
                        w["resets_at"] = 0
                    if k == "secondary" and w.get("label") == "7d":
                        w["label"] = "1w"
            return d
    except Exception:
        pass
    return None

# 1. Test fixture JSON
test_json = os.environ.get("GEMINI_USAGE_TEST_JSON")
if test_json and os.path.isfile(test_json):
    try:
        with open(test_json, "r", encoding="utf-8") as f:
            d = json.load(f)
        if "response" in d or "groups" in d:
            res = parse_quota_summary(d, "Google AI", "fixture")
            if res:
                res["fetched_at"] = now
                print(json.dumps(res))
                sys.exit(0)
        elif "userStatus" in d:
            res = parse_ustatus_obj(d["userStatus"], "fixture")
            if res:
                res["fetched_at"] = now
                print(json.dumps(res))
                sys.exit(0)
        elif "primary" in d:
            d["source"] = "fixture"
            d["fetched_at"] = now
            print(json.dumps(d))
            sys.exit(0)
        else:
            res = build_result("fixture", "Google AI", d if isinstance(d, list) else [d])
            if res:
                res["fetched_at"] = now
                print(json.dumps(res))
                sys.exit(0)
    except Exception:
        pass

cached_live = load_cached_live()
cached_sec = cached_live.get("secondary") if isinstance(cached_live, dict) else None

def query_ls_endpoint(scheme, port, token):
    try:
        port_num = int(port)
        if port_num < 1 or port_num > 65535 or not token or any(c.isspace() for c in str(token)):
            return None
    except Exception:
        return None
    base_url = f"{scheme}://127.0.0.1:{port_num}/exa.language_server_pb.LanguageServerService"
    headers = [
        "-H", f"x-codeium-csrf-token: {token}",
        "-H", "Connect-Protocol-Version: 1",
        "-H", "Content-Type: application/json",
    ]
    payload = '{"metadata":{"ideName":"antigravity","extensionName":"antigravity","locale":"en"}}'
    plan = None
    ustatus = None
    try:
        out_u = subprocess.check_output(
            ["curl", "-k", "-s", "-m", "2", "-X", "POST", f"{base_url}/GetUserStatus"] + headers + ["-d", payload],
            stderr=subprocess.DEVNULL
        )
        if out_u and b"userStatus" in out_u:
            ustatus = (json.loads(out_u).get("userStatus") or {})
            tier = ustatus.get("userTier") or {}
            plan = tier.get("name") or ustatus.get("plan")
    except Exception:
        pass
    try:
        out_q = subprocess.check_output(
            ["curl", "-k", "-s", "-m", "2", "-X", "POST", f"{base_url}/RetrieveUserQuotaSummary"] + headers + ["-d", "{}"],
            stderr=subprocess.DEVNULL
        )
        if out_q and b"groups" in out_q:
            res = parse_quota_summary(json.loads(out_q), plan or "Google AI", "live")
            if res:
                return res
    except Exception:
        pass
    if ustatus:
        configs = (ustatus.get("cascadeModelConfigData") or {}).get("clientModelConfigs") or []
        res = build_result("live", plan, configs, fallback_secondary=cached_sec)
        if res:
            return res
    return None

def pid_alive(pid):
    if os.environ.get("ANTIGRAVITY_DAEMON_SKIP_PID_CHECK") == "1":
        return True
    try:
        p = int(pid)
        if p <= 0:
            return False
        os.kill(p, 0)
        return True
    except PermissionError:
        return True
    except Exception:
        return False

# Tier 1a: Antigravity 2.x daemon registry (~/.gemini/antigravity/daemon/*.json)
def try_daemon_registry():
    daemon_dir = os.environ.get("ANTIGRAVITY_DAEMON_DIR") or os.path.expanduser("~/.gemini/antigravity/daemon")
    if not os.path.isdir(daemon_dir):
        return None
    try:
        files = sorted(glob.glob(os.path.join(daemon_dir, "*.json")), key=os.path.getmtime, reverse=True)
    except Exception:
        return None
    for fp in files:
        try:
            with open(fp, "r", encoding="utf-8") as f:
                info = json.load(f)
            if not isinstance(info, dict):
                continue
            pid = info.get("pid")
            token = info.get("csrfToken")
            if not token or not pid_alive(pid):
                continue
            endpoints = []
            if info.get("httpsPort"):
                endpoints.append(("https", info.get("httpsPort")))
            if info.get("httpPort"):
                endpoints.append(("http", info.get("httpPort")))
            for scheme, port in endpoints:
                res = query_ls_endpoint(scheme, port, token)
                if res:
                    return res
        except Exception:
            continue
    return None

# Tier 1b: Legacy language_server CLI inspection (Antigravity 1.x / IDE with --csrf_token)
def try_language_server():
    res = try_daemon_registry()
    if res:
        return res
    if os.environ.get("ANTIGRAVITY_DAEMON_ONLY") == "1":
        return None
    try:
        ps_out = subprocess.check_output(["ps", "-ax", "-o", "pid=,command="], stderr=subprocess.DEVNULL).decode("utf-8")
    except Exception:
        return None
    candidates = []
    for line in ps_out.splitlines():
        line = line.strip()
        if "language_server" in line and "--csrf_token" in line:
            parts = line.split(None, 1)
            if len(parts) == 2:
                pid = parts[0]
                cmd = parts[1]
                m_token = re.search(r"--csrf_token\s+([^\s]+)", cmd)
                if m_token:
                    token = m_token.group(1)
                    score = 0
                    if "--subclient_type hub" in cmd or "Antigravity.app" in cmd:
                        score = 2
                    elif "--subclient_type ide" in cmd or "Antigravity IDE.app" in cmd:
                        score = 1
                    candidates.append((score, pid, token))
    candidates.sort(key=lambda x: x[0], reverse=True)
    for _, pid, token in candidates:
        try:
            lsof_out = subprocess.check_output(["lsof", "-nP", "-iTCP", "-sTCP:LISTEN", "-a", "-p", pid], stderr=subprocess.DEVNULL).decode("utf-8")
            ports = re.findall(r"127\.0\.0\.1:(\d+)", lsof_out)
            for port in set(ports):
                for scheme in ("https", "http"):
                    res = query_ls_endpoint(scheme, port, token)
                    if res:
                        return res
        except Exception:
            pass
    return None

# Tier 2: state.vscdb (never overwrite a fresher live 2-window cache with an older offline DB)
def try_vscdb():
    dbs = []
    custom_db = os.environ.get("ANTIGRAVITY_STATE_DB")
    if custom_db and os.path.isfile(custom_db):
        dbs.append(custom_db)
    elif os.environ.get("ANTIGRAVITY_DAEMON_ONLY") == "1":
        return None
    else:
        home = os.path.expanduser("~")
        dbs.append(os.path.join(home, "Library/Application Support/Antigravity/User/globalStorage/state.vscdb"))
        dbs.append(os.path.join(home, "Library/Application Support/Antigravity IDE/User/globalStorage/state.vscdb"))
    cached_ts = int(cached_live.get("fetched_at") or 0) if isinstance(cached_live, dict) else 0
    for db in dbs:
        if not os.path.isfile(db):
            continue
        try:
            if not custom_db and cached_ts > 0 and os.path.getmtime(db) < cached_ts:
                continue
            conn = sqlite3.connect(f"file:{db}?mode=ro", uri=True)
            c = conn.cursor()
            c.execute("SELECT value FROM ItemTable WHERE key = 'antigravityUnifiedStateSync.userStatus'")
            row = c.fetchone()
            conn.close()
            if not row or not row[0]:
                continue
            val = row[0]
            raw = base64.b64decode(val)
            m = re.search(rb'[A-Za-z0-9+/=]{100,}', raw)
            if not m:
                continue
            inner_raw = base64.b64decode(m.group(0))
            plan_match = re.search(rb'Google AI [A-Za-z]+', inner_raw)
            plan = plan_match.group(0).decode('utf-8') if plan_match else "Google AI"
            models = []
            for m in re.finditer(rb'(?:Gemini|Orchestrator) [^\x00-\x1f]+', inner_raw):
                name = m.group(0).decode('utf-8', errors='ignore')
                pos = m.end()
                chunk = inner_raw[pos:pos+80]
                q_pos = chunk.find(b'z\r\r')
                if q_pos != -1:
                    flt_bytes = chunk[q_pos+3:q_pos+7]
                    if len(flt_bytes) == 4:
                        rem_frac = struct.unpack('<f', flt_bytes)[0]
                        time_match = re.search(rb'\x12[\x01-\x10]\x08([\x80-\xff]*[\x00-\x7f])', chunk[q_pos+7:])
                        reset_ts = None
                        if time_match:
                            v_bytes = time_match.group(1)
                            ts = 0; shift = 0
                            for b in v_bytes:
                                ts |= (b & 0x7f) << shift
                                shift += 7
                            reset_ts = ts
                        models.append({'name': name, 'remainingFraction': rem_frac, 'resetTime': reset_ts})
            res = build_result("state.vscdb", plan, models, fallback_secondary=cached_sec)
            if res:
                return res
        except Exception:
            pass
    return None

res = try_language_server()
if not res:
    res = try_vscdb()

if res:
    print(json.dumps(res))
else:
    print("")
PY
}

# Determine if cache can be used
NOW="$(now_epoch)"
INTERVAL="$DEFAULT_INTERVAL"
if [[ -f "$INTERVAL_FILE" ]]; then
  VAL="$(cat "$INTERVAL_FILE" 2>/dev/null || true)"
  [[ "$VAL" =~ ^[0-9]+$ ]] && INTERVAL="$VAL"
fi

DATA=""
MTIME="$(file_mtime "$CACHE_FILE")"
AGE=$(( NOW - MTIME ))

# If cache is fresh and neither test json nor force refresh is set, use cache
if [[ "$FORCE_REFRESH" == "0" && -z "${GEMINI_USAGE_TEST_JSON:-}" && -s "$CACHE_FILE" && $AGE -lt $INTERVAL ]]; then
  DATA="$(cat "$CACHE_FILE" 2>/dev/null || true)"
  [[ "$DATA" == *'"source": "fixture"'* || "$DATA" == *'"source":"fixture"'* ]] && DATA=""
fi

if [[ -z "$DATA" ]]; then
  FETCHED="$(fetch_data)"
  if [[ -n "$FETCHED" && "$FETCHED" != "null" ]]; then
    DATA="$FETCHED"
    TMP_CACHE="$CACHE_FILE.tmp.$$"
    if printf '%s\n' "$DATA" > "$TMP_CACHE" 2>/dev/null; then
      chmod 600 "$TMP_CACHE" 2>/dev/null || true
      mv -f "$TMP_CACHE" "$CACHE_FILE" 2>/dev/null || rm -f "$TMP_CACHE" 2>/dev/null || true
    fi
    : > "$ERROR_FILE" 2>/dev/null || true
  elif [[ -s "$CACHE_FILE" ]]; then
    # Fallback to stale cache
    DATA="$(cat "$CACHE_FILE" 2>/dev/null || true)"
  fi
fi

if [[ "${1:-}" == "--json" ]]; then
  if [[ -n "$DATA" ]]; then
    printf '%s\n' "$DATA"
  else
    printf '{"error":"Waiting for Antigravity data"}\n'
  fi
  exit 0
fi

if [[ -z "$DATA" || "$DATA" == "null" ]]; then
  echo "⚠ | color=$DANGER_COLOR"
  echo "---"
  echo "Waiting for Antigravity data | color=$DANGER_COLOR"
  echo "Open Antigravity or Antigravity IDE once | color=$MUTED_COLOR"
  echo "Refresh now | refresh=true"
  exit 0
fi

{
  read -r P_LABEL
  read -r P_USED
  read -r P_RESET
  read -r HAS_SEC
  read -r S_LABEL
  read -r S_USED
  read -r S_RESET
  read -r PLAN
  read -r SOURCE
  read -r FETCHED_AT
} < <(python3 -c "
import json, sys
try:
    d = json.loads(sys.argv[1])
except Exception:
    d = {}
p = d.get('primary') or {}
s = d.get('secondary') or {}
has_sec = bool(s)
s_lbl = (s.get('label') or '1w') if has_sec else ''
if s_lbl == '7d':
    s_lbl = '1w'
print(p.get('label') or '5h')
print(p.get('used_percent', 0))
print(p.get('resets_at', 0))
print('true' if has_sec else 'false')
print(s_lbl)
print(s.get('used_percent', 0) if has_sec else 0)
print(s.get('resets_at', 0) if has_sec else 0)
print(d.get('plan') or '')
print(d.get('source') or 'unknown')
print(d.get('fetched_at') or 0)
" "$DATA")

P_USED_I="$(clamp_percent "$P_USED")"
S_USED_I="$(clamp_percent "$S_USED")"
WORST="$P_USED_I"
if [[ "$HAS_SEC" == "true" ]] && (( S_USED_I > WORST )); then
  WORST="$S_USED_I"
fi
COLOR="$(color_for "$WORST")"

P_BAR="$(usage_bar "$P_USED_I" "$MBAR_W")"
TITLE="Gemini ${P_LABEL} ${P_BAR}"
if [[ "$HAS_SEC" == "true" ]]; then
  S_BAR="$(usage_bar "$S_USED_I" "$MBAR_W")"
  TITLE="Gemini ${P_LABEL} ${P_BAR}  ${S_LABEL} ${S_BAR}"
fi

echo "$TITLE | color=$COLOR font=Menlo"
echo "---"
echo "Gemini usage | color=$COLOR"
[[ -n "$PLAN" ]] && echo "Plan: $PLAN | color=$MUTED_COLOR"
echo "---"

P_RST_STR="$(format_reset "$P_RESET")"
echo "$P_LABEL   $(usage_bar "$P_USED_I" "$DROP_W")   ${P_USED_I}% used | color=$(color_for "$P_USED_I") font=Menlo"
if [[ -n "$P_RST_STR" ]]; then
  echo "     $((100-P_USED_I))% left · resets in $P_RST_STR | color=$MUTED_COLOR font=Menlo size=11"
else
  echo "     $((100-P_USED_I))% left | color=$MUTED_COLOR font=Menlo size=11"
fi

if [[ "$HAS_SEC" == "true" ]]; then
  S_RST_STR="$(format_reset "$S_RESET")"
  echo "$S_LABEL   $(usage_bar "$S_USED_I" "$DROP_W")   ${S_USED_I}% used | color=$(color_for "$S_USED_I") font=Menlo"
  if [[ -n "$S_RST_STR" ]]; then
    echo "     $((100-S_USED_I))% left · resets in $S_RST_STR | color=$MUTED_COLOR font=Menlo size=11"
  else
    echo "     $((100-S_USED_I))% left | color=$MUTED_COLOR font=Menlo size=11"
  fi
fi

echo "---"
if [[ "$SOURCE" == "live" ]]; then
  echo "Source: live local language_server | color=$MUTED_COLOR"
elif [[ "$SOURCE" == "fixture" ]]; then
  echo "Source: test fixture | color=$MUTED_COLOR"
elif [[ "$SOURCE" == "state.vscdb" ]]; then
  echo "Source: offline state.vscdb | color=$MUTED_COLOR"
else
  echo "Source: cached reading | color=$WARN_COLOR"
fi
(( FETCHED_AT > 0 )) && echo "Updated: $(format_local_time "$FETCHED_AT") | color=$MUTED_COLOR"

echo "---"
CURRENT_INTERVAL="$(cat "$INTERVAL_FILE" 2>/dev/null || printf '%s' "$DEFAULT_INTERVAL")"
echo "⏱ Update every $((CURRENT_INTERVAL/60)) min"
echo "--1 min | bash='$0' param1=--set-interval param2=60 terminal=false refresh=true"
echo "--3 min | bash='$0' param1=--set-interval param2=180 terminal=false refresh=true"
echo "--5 min | bash='$0' param1=--set-interval param2=300 terminal=false refresh=true"
echo "Refresh now | bash='$0' param1=--clear-cache terminal=false refresh=true"
echo "Open Antigravity | href=https://antigravity.google/"
echo "Version v$VERSION | color=$MUTED_COLOR"
