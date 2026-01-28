#!/usr/bin/env bash
set -euo pipefail

export HOME=/home/browser
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"

CDP_PORT="${CLAWDBOT_BROWSER_CDP_PORT:-9222}"
HEADLESS="${CLAWDBOT_BROWSER_HEADLESS:-1}"
CHROME_CDP_PORT=9223  # Internal port, nginx proxies from CDP_PORT

mkdir -p "${HOME}/.chrome" "${XDG_CONFIG_HOME}" "${XDG_CACHE_HOME}"

CHROME_ARGS=(
  "--remote-debugging-address=127.0.0.1"
  "--remote-debugging-port=${CHROME_CDP_PORT}"
  "--remote-allow-origins=*"
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

# Start nginx to proxy CDP with Host header rewrite
echo "Starting nginx CDP proxy on 0.0.0.0:${CDP_PORT}..."
nginx -g 'daemon off;' &

echo "moltbot-sandbox-browser is ready. CDP available at port ${CDP_PORT}"

wait -n
