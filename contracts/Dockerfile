FROM node:24-bookworm-slim as eth-contracts

# 文字コードと非対話モードの設定
ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

# 1. 必要なツールをまとめてインストール
# build-essential: make, gcc, g++ を提供
# python3-venv: Slitherインストール用
# git: Hardhatのプラグインやライブラリで要求されることが多い
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    git \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. Slither (Python 仮想環境) のセットアップ
# 最近のDebianでのpip install制限を回避し、パスを通す
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir slither-analyzer

# 3. npm の最新化 (Node 24 は標準で新しいですが、念のため)
RUN npm install -g npm@latest

# 4. 作業ディレクトリの設定
WORKDIR /app/src

# Hardhat Network (Node) 用のポート
EXPOSE 8545
