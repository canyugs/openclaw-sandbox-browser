# OpenClaw Sandbox Browser

Headless Chromium browser sandbox for [OpenClaw](https://github.com/openclaw/openclaw).

This container provides a headless Chromium browser that OpenClaw can control via Chrome DevTools Protocol (CDP).

## Quick Start

```bash
# Pull the image
docker pull ghcr.io/canyugs/openclaw-sandbox-browser:main

# Run in headless mode
docker run -d -p 9222:9222 ghcr.io/canyugs/openclaw-sandbox-browser:main

# Test CDP is working
curl http://localhost:9222/json/version
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `OPENCLAW_BROWSER_CDP_PORT` | `9222` | CDP port to expose |
| `OPENCLAW_BROWSER_HEADLESS` | `1` | Run in headless mode (1=yes, 0=no) |
| `OPENCLAW_BROWSER_VNC_PORT` | `5900` | VNC server port |
| `OPENCLAW_BROWSER_NOVNC_PORT` | `6080` | noVNC web interface port |
| `OPENCLAW_BROWSER_ENABLE_NOVNC` | `1` | Enable noVNC (1=yes, 0=no) |

> **Note:** Legacy environment variables `MOLTBOT_BROWSER_*` and `CLAWDBOT_BROWSER_*` are also supported for backward compatibility.

## Usage with OpenClaw

In your OpenClaw configuration (`openclaw.json`):

```json
{
  "browser": {
    "enabled": true,
    "attachOnly": true,
    "defaultProfile": "remote",
    "profiles": {
      "remote": {
        "cdpUrl": "http://openclaw-sandbox-browser:9222",
        "color": "#FF4500"
      }
    }
  }
}
```

## Visual Debugging (VNC/noVNC)

By default, the browser runs in headless mode for better performance. To enable visual debugging:

### Enable Desktop Mode

```bash
# Run with desktop mode enabled
docker run -d \
  -p 9222:9222 \
  -p 6080:6080 \
  -p 5900:5900 \
  -e OPENCLAW_BROWSER_HEADLESS=0 \
  ghcr.io/canyugs/openclaw-sandbox-browser:main
```

### Access Methods

| Method | Port | URL/Connection |
|--------|------|----------------|
| **noVNC (Web)** | 6080 | Open `http://localhost:6080` in browser |
| **VNC Client** | 5900 | Connect to `localhost:5900` with any VNC client |

### Ports Overview

| Port | Protocol | Description |
|------|----------|-------------|
| `9222` | HTTP/WebSocket | Chrome DevTools Protocol (CDP) |
| `6080` | HTTP | noVNC web interface |
| `5900` | TCP | VNC server (no password) |

## Building

```bash
docker build -t openclaw-sandbox-browser:local .
```

## Architecture

- Based on `debian:bookworm-slim` for minimal footprint
- Includes Chromium with CJK fonts support
- Uses Caddy as reverse proxy for CDP (handles Host header rewrite)
- Includes X11 virtual framebuffer (Xvfb) for non-headless mode
- Includes x11vnc and noVNC for remote desktop access

## Deploy on Zeabur

[![Deploy on Zeabur](https://zeabur.com/button.svg)](https://zeabur.com/templates/H8L4G1)

## License

MIT
