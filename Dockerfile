# Build stage
FROM node:18-slim as builder



ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

RUN apt-get update && apt-get install gnupg wget -y && \
  wget --quiet --output-document=- https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /etc/apt/trusted.gpg.d/google-archive.gpg && \
  sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' && \
  apt-get update && \
  apt-get install google-chrome-stable -y --no-install-recommends && \
  rm -rf /var/lib/apt/lists/*

USER node
WORKDIR /home/node

COPY package*.json .
RUN npm ci

COPY --chown=node:node . .
RUN npm run build
ENV NODE_ENV production

# Final run stage
# FROM node:18-slim

# USER node
# WORKDIR /home/node

# COPY --from=builder --chown=node:node /home/node/package*.json .
# COPY --from=builder --chown=node:node /home/node/node_modules ./node_modules
# COPY --from=builder --chown=node:node /home/node/dist ./dist
# COPY --from=builder --chown=node:node /usr/bin/google-chrome /usr/bin/google-chrome

ARG PORT
EXPOSE ${PORT:-3000}

CMD ["node", "dist/main.js"]