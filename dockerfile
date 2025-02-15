FROM node:20.18 AS base

RUN npm i -g pnpm

FROM base AS dependencies

WORKDIR /usr/src/app

COPY package.json pnpm-lock.yaml ./

RUN pnpm install

FROM base AS build

WORKDIR /usr/src/app

COPY . .
COPY --from=dependencies /usr/src/app/node_modules ./node_modules

RUN pnpm build
RUN pnpm prune --prod

FROM cgr.dev/chainguard/node:latest AS deploy

USER 1000

WORKDIR /usr/src/app

COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/package.json ./package.json

ENV CLOUDFLARE_ACCESS_KEY_ID="7519514fdf40dc26ce77228161ccc785"
ENV CLOUDFLARE_SECRET_ACCESS_KEY="c19387e5f65aa5dc79f86260e31c4603a1c53da3cf04cc26528943b9f64d882f"
ENV CLOUDFLARE_BUCKET="ftr-upload-widget"
ENV CLOUDFLARE_ACCOUNT_ID="6ff212e12227a71ebdb4b0363ca96935"
ENV CLOUDFLARE_PUBLIC_URL="https://pub-95b3891d7b164714b012f065d42d2c29.r2.dev"

EXPOSE 3333

CMD ["dist/server.mjs"]