FROM debian:bookworm-slim

LABEL org.opencontainers.image.source="https://github.com/canyugs/moltbot-sandbox-browser"
LABEL org.opencontainers.image.description="Headless Chromium browser sandbox for moltbot"
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
    socat \
  && rm -rf /var/lib/apt/lists/*

# Create non-root user for security
RUN useradd -m -s /bin/bash browser

COPY entrypoint.sh /usr/local/bin/moltbot-sandbox-browser
RUN chmod +x /usr/local/bin/moltbot-sandbox-browser

USER browser
WORKDIR /home/browser

EXPOSE 9222

CMD ["moltbot-sandbox-browser"]
