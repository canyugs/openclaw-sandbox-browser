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
    nginx \
  && rm -rf /var/lib/apt/lists/*

# Configure nginx as reverse proxy to rewrite Host header
RUN echo 'server { \n\
    listen 9222; \n\
    location / { \n\
        proxy_pass http://127.0.0.1:9223; \n\
        proxy_http_version 1.1; \n\
        proxy_set_header Host localhost; \n\
        proxy_set_header Upgrade $http_upgrade; \n\
        proxy_set_header Connection "upgrade"; \n\
    } \n\
}' > /etc/nginx/sites-available/cdp-proxy \
  && ln -sf /etc/nginx/sites-available/cdp-proxy /etc/nginx/sites-enabled/ \
  && rm -f /etc/nginx/sites-enabled/default

# Create non-root user for security
RUN useradd -m -s /bin/bash browser

COPY entrypoint.sh /usr/local/bin/moltbot-sandbox-browser
RUN chmod +x /usr/local/bin/moltbot-sandbox-browser

USER browser
WORKDIR /home/browser

EXPOSE 9222

CMD ["moltbot-sandbox-browser"]
