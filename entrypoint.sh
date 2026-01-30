#!/usr/bin/env bash
set -euo pipefail

export DISPLAY=:1
export HOME=/tmp/openclaw-home
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"

# Support OPENCLAW_*, MOLTBOT_*, and legacy CLAWDBOT_* env vars
CDP_PORT="${OPENCLAW_BROWSER_CDP_PORT:-${MOLTBOT_BROWSER_CDP_PORT:-${CLAWDBOT_BROWSER_CDP_PORT:-9222}}}"
VNC_PORT="${OPENCLAW_BROWSER_VNC_PORT:-${MOLTBOT_BROWSER_VNC_PORT:-${CLAWDBOT_BROWSER_VNC_PORT:-5900}}}"
NOVNC_PORT="${OPENCLAW_BROWSER_NOVNC_PORT:-${MOLTBOT_BROWSER_NOVNC_PORT:-${CLAWDBOT_BROWSER_NOVNC_PORT:-6080}}}"
ENABLE_NOVNC="${OPENCLAW_BROWSER_ENABLE_NOVNC:-${MOLTBOT_BROWSER_ENABLE_NOVNC:-${CLAWDBOT_BROWSER_ENABLE_NOVNC:-1}}}"
HEADLESS="${OPENCLAW_BROWSER_HEADLESS:-${MOLTBOT_BROWSER_HEADLESS:-${CLAWDBOT_BROWSER_HEADLESS:-0}}}"

mkdir -p "${HOME}" "${HOME}/.chrome" "${XDG_CONFIG_HOME}" "${XDG_CACHE_HOME}"

Xvfb :1 -screen 0 1280x800x24 -ac -nolisten tcp &

if [[ "${HEADLESS}" == "1" ]]; then
  CHROME_ARGS=(
    "--headless=new"
    "--disable-gpu"
  )
else
  CHROME_ARGS=()
fi

if [[ "${CDP_PORT}" -ge 65535 ]]; then
  CHROME_CDP_PORT="$((CDP_PORT - 1))"
else
  CHROME_CDP_PORT="$((CDP_PORT + 1))"
fi

CHROME_ARGS+=(
  "--remote-debugging-address=127.0.0.1"
  "--remote-debugging-port=${CHROME_CDP_PORT}"
  "--user-data-dir=${HOME}/.chrome"
  "--no-first-run"
  "--no-default-browser-check"
  "--disable-dev-shm-usage"
  "--disable-background-networking"
  "--disable-features=TranslateUI"
  "--disable-breakpad"
  "--disable-crash-reporter"
  "--metrics-recording-only"
  "--no-sandbox"
)

chromium "${CHROME_ARGS[@]}" about:blank &

for _ in $(seq 1 50); do
  if curl -sS --max-time 1 "http://127.0.0.1:${CHROME_CDP_PORT}/json/version" >/dev/null; then
    break
  fi
  sleep 0.1
done

# Use Caddy as reverse proxy to rewrite Host header to localhost
# This bypasses Chrome's "Host header is not an IP address or localhost" check
cat > /tmp/Caddyfile << EOF
{
  auto_https off
  admin off
}
:${CDP_PORT} {
  reverse_proxy 127.0.0.1:${CHROME_CDP_PORT} {
    header_up Host 127.0.0.1
  }
}
EOF

caddy run --config /tmp/Caddyfile &

if [[ "${ENABLE_NOVNC}" == "1" && "${HEADLESS}" != "1" ]]; then
  x11vnc -display :1 -rfbport "${VNC_PORT}" -shared -forever -nopw -localhost &
  websockify --web /usr/share/novnc/ "${NOVNC_PORT}" "localhost:${VNC_PORT}" &
fi

wait -n
