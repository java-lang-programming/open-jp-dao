FROM node:18.17.1-buster as eth-contracts

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# timezoneの選択で止まるのを防ぐ
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y && npm install -g npm
# apt install -y python3.11 && apt install python3-pip && pip3 install slither-analyzer
# コンテナ内に作業ディレクトリを作成
RUN mkdir -p /app/src/
# コンテナログイン時のディレクトリ指定
WORKDIR /app/src/

EXPOSE 8545
