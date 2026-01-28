#!/usr/bin/env bash
set -euo pipefail

export HOME=/home/browser
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"

CDP_PORT="${CLAWDBOT_BROWSER_CDP_PORT:-9222}"
HEADLESS="${CLAWDBOT_BROWSER_HEADLESS:-1}"

mkdir -p "${HOME}/.chrome" "${XDG_CONFIG_HOME}" "${XDG_CACHE_HOME}"

# Calculate internal Chrome port (different from exposed port for socat proxy)
if [[ "${CDP_PORT}" -ge 65535 ]]; then
  CHROME_CDP_PORT="$((CDP_PORT - 1))"
else
  CHROME_CDP_PORT="$((CDP_PORT + 1))"
fi

CHROME_ARGS=(
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
  "--disable-setuid-sandbox"
)

if [[ "${HEADLESS}" == "1" ]]; then
  CHROME_ARGS+=(
    "--headless=new"
    "--disable-gpu"
  )
fi

echo "Starting Chromium with CDP on port ${CDP_PORT}..."
chromium "${CHROME_ARGS[@]}" about:blank &

# Wait for Chrome to start
echo "Waiting for Chrome CDP to be ready..."
for _ in $(seq 1 50); do
  if curl -sS --max-time 1 "http://127.0.0.1:${CHROME_CDP_PORT}/json/version" >/dev/null 2>&1; then
    echo "Chrome CDP is ready on internal port ${CHROME_CDP_PORT}"
    break
  fi
  sleep 0.1
done

# Start socat to proxy CDP port to all interfaces
echo "Starting CDP proxy on 0.0.0.0:${CDP_PORT}..."
socat \
  TCP-LISTEN:"${CDP_PORT}",fork,reuseaddr,bind=0.0.0.0 \
  TCP:127.0.0.1:"${CHROME_CDP_PORT}" &

echo "moltbot-sandbox-browser is ready. CDP available at port ${CDP_PORT}"

wait -n
