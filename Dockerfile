FROM debian:bookworm-slim

LABEL org.opencontainers.image.source="https://github.com/canyugs/openclaw-sandbox-browser"
LABEL org.opencontainers.image.description="Headless Chromium browser sandbox for OpenClaw"
LABEL org.opencontainers.image.licenses="MIT"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    chromium \
    curl \
    fonts-liberation \
    fonts-noto-color-emoji \
    fonts-noto-cjk \
    git \
    jq \
    novnc \
    python3 \
    socat \
    websockify \
    x11vnc \
    xvfb \
  && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/local/bin/openclaw-sandbox-browser
COPY cdp_proxy.py /usr/local/bin/cdp_proxy.py
RUN chmod +x /usr/local/bin/openclaw-sandbox-browser

EXPOSE 9222 5900 6080

CMD ["openclaw-sandbox-browser"]
