FROM node:18.20.3-buster

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# timezoneの選択で止まるのを防ぐ
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y && npm install -g pnpm@9.4.0
# コンテナ内に作業ディレクトリを作成
RUN mkdir -p /app/src/
# コンテナログイン時のディレクトリ指定
WORKDIR /app/src/

EXPOSE 3000
