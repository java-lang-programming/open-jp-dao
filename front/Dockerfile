# =========================
# 1. Build stage
# =========================
FROM node:18.20.8-alpine3.20 AS node_builder

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app/

# pnpm を明示的にインストール（バージョン固定推奨）
RUN npm install -g pnpm@9.4.0

# 依存関係のインストール（キャッシュ効率を考慮）
COPY ./src/sample/sample/package.json ./src/sample/sample/pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# ソースコードをコピー
COPY ./src/sample/sample/. .

# Next.js build
RUN pnpm build

# =========================
# 2. Production stage
# =========================
FROM node:18.20.8-alpine3.20 AS node_runner

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app/

ENV NODE_ENV=production

# pnpm を明示的にインストール（バージョン固定推奨）
RUN npm install -g pnpm@9.4.0

# 必要最小限のみコピー
COPY --from=node_builder /usr/src/app/package.json ./
COPY --from=node_builder /usr/src/app/node_modules ./node_modules
COPY --from=node_builder /usr/src/app/.next ./.next
COPY --from=node_builder /usr/src/app/public ./public
COPY --from=node_builder /usr/src/app/next.config.js ./next.config.js

EXPOSE 3000
CMD ["pnpm", "start"]