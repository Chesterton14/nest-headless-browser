FROM node:18 as builder

RUN npm i pnpm@8.4.0 -g

WORKDIR /usr/src/app

COPY . .
RUN pnpm install

ENV NODE_ENV production
RUN pnpm build

ARG PORT
EXPOSE ${PORT:-3000}

CMD ["node", "dist/main.js"]