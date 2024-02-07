FROM node:18 as builder

RUN apt-get update \
 && apt-get -y install libnss3-dev libgdk-pixbuf2.0-dev libgtk-3-dev libxss-dev

RUN npm i pnpm@8.4.0 -g

WORKDIR /usr/src/app

COPY . .
RUN pnpm install

ENV NODE_ENV production
RUN pnpm build

ARG PORT
EXPOSE ${PORT:-3000}

CMD ["node", "dist/main.js"]