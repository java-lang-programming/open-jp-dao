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

