# Build stage
FROM node:lts-alpine AS builder

USER node
WORKDIR /home/node

COPY package*.json .
# RUN npm ci
RUN sudo npm i pnpm -g
RUN pnpm install

COPY --chown=node:node . .
RUN pnpm build && npm prune --omit=dev


# Final run stage
FROM node:lts-alpine

ENV NODE_ENV production
USER node
WORKDIR /home/node

COPY --from=builder --chown=node:node /home/node/package*.json .
COPY --from=builder --chown=node:node /home/node/node_modules ./node_modules
COPY --from=builder --chown=node:node /home/node/dist ./dist
COPY --from=builder --chown=node:node /home/node/.cache ./cache

ARG PORT
EXPOSE ${PORT:-3000}

CMD ["node", "dist/main.js"]