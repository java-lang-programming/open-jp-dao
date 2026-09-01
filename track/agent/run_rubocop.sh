#!/bin/bash

#!/usr/bin/env bash
set -uo pipefail

# 第1引数が渡されればそれを使い、無ければ空文字（全体指定）にする
TARGET_PATH=${1:-""}

# Dockerデーモン自体が立ち上がっているかを判定
if ! docker info >/dev/null 2>&1; then
  ./scripts/json_formatter.sh "error" 1 "$TARGET_PATH" "エラー: Dockerが起動していません。Docker DesktopまたはDockerサービスを立ち上げてください。"
  exit 1
fi

CONTAINER_ID=$(docker ps --filter "status=running" --format "{{.ID}}\t{{.Names}}" | grep "wevb3-rails-dev" | head -n 1 | awk '{print $1}'|| true)

# コンテナが見つからない場合のフォールバック（自動化エラーハンドリング）
if [ -z "$CONTAINER_ID" ]; then
  ./scripts/json_formatter.sh "error" 1 "$TARGET_PATH" "エラー: 実行対象のDev Containerが見つかりません。コンテナが起動しているか確認してください。"
  exit 1
fi

# 2. 検出したコンテナに対して直接 docker exec を実行（-i でTTYなし実行）
# Dockerコンテナの中でRSpecを実行し、その『出力ログ』を $OUTPUT に、『成功か失敗かの数字』を $EXIT_CODE に保存
# 成功した時、EXIT_CODE に 0 EXIT_CODE に 1 などの失敗コード
OUTPUT=$(docker exec -i "$CONTAINER_ID" bin/rubocop $TARGET_PATH 2>&1)

# ターミナルから人間が直接叩いている場合は画面に出力
# (※手動実行で確実に画面表示させるため [ -t 0 ] または [ -t 1 ] を使用)
if [ -t 0 ] || [ -t 1 ]; then
  echo "---------------- [ RSpec Output ] ----------------"
  echo "$OUTPUT"
  echo "--------------------------------------------------"
  echo "Exit Code: $EXIT_CODE"
fi

STATUS=$([ $EXIT_CODE -eq 0 ] && echo "success" || echo "failure")
# # 最終的なJSON出力（AI Agent用）
./scripts/json_formatter.sh "$STATUS" "$EXIT_CODE" "$TARGET_PATH" "$OUTPUT"
