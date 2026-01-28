# moltbot-sandbox-browser

Headless Chromium browser sandbox for [moltbot](https://github.com/moltbot/moltbot).

This container provides a headless Chromium browser that moltbot can control via Chrome DevTools Protocol (CDP).

## Quick Start

```bash
# Pull the image
docker pull ghcr.io/zeabur/moltbot-sandbox-browser:main

# Run in headless mode
docker run -d -p 9222:9222 ghcr.io/zeabur/moltbot-sandbox-browser:main

# Test CDP is working
curl http://localhost:9222/json/version
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CLAWDBOT_BROWSER_CDP_PORT` | `9222` | CDP port to expose |
| `CLAWDBOT_BROWSER_HEADLESS` | `1` | Run in headless mode (1=yes, 0=no) |

## Usage with moltbot

In your moltbot configuration (`clawdbot.json`):

```json
{
  "browser": {
    "enabled": true,
    "cdpUrl": "http://moltbot-browser:9222",
    "attachOnly": true,
    "headless": true
  }
}
```

## Building

```bash
docker build -t moltbot-sandbox-browser:local .
```

## Architecture

- Based on `debian:bookworm-slim` for minimal footprint
- Includes Chromium with CJK fonts support
- Runs as non-root user for security
- Uses socat to proxy CDP to all interfaces

## License

MIT
