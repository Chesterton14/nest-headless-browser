# Build stage
FROM node:18-alpine as builder

RUN apk add --no-cache \
  chromium \
  nss \
  freetype \
  harfbuzz \
  ca-certificates \
  ttf-freefont 

ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
RUN addgroup -S pptruser && adduser -S -G pptruser pptruser \
  && mkdir -p /home/pptruser/Downloads /app \
  && chown -R pptruser:pptruser /home/pptruser \
  && chown -R pptruser:pptruser /app

USER pptruser
WORKDIR /home/pptruser

COPY package*.json .
RUN npm ci

COPY --chown=pptruser:pptruser . .
RUN npm run build && npm prune --omit=dev


# Final run stage
FROM node:18-alpine

ENV NODE_ENV production
USER pptruser
WORKDIR /home/pptruser

COPY --from=builder --chown=pptruser:pptruser /home/pptruser/package*.json .
COPY --from=builder --chown=pptruser:pptruser /home/pptruser/node_modules ./node_modules
COPY --from=builder --chown=pptruser:pptruser /home/pptruser/dist ./dist
COPY --from=builder --chown=pptruser:pptruser /home/pptruser/.cache ./.cache

ARG PORT
EXPOSE ${PORT:-3000}

CMD ["node", "dist/main.js"]