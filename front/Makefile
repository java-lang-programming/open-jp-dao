RULE_REGEX := ^[a-zA-Z_][a-zA-Z0-9_-]+:
RULE_AND_DESC_REGEX := $(RULE_REGEX).*?## .*$$
EXTRA_COMMENT_REGEX := ^## .* ##$$
.ONESHELL:
.DEFAULT_GOAL := help
.PHONY: help

# INFO: 参考サイト - https://postd.cc/auto-documented-makefile/ https://zenn.dev/loglass/articles/0016-make-makefile
help:
	@grep -E $(RULE_AND_DESC_REGEX) $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

## docker操作 ##
dc_build: ## Docker環境のビルド
	docker-compose -f .devcontainer/compose.yaml build
dc_up: ## Docker環境の立ち上げ
	docker-compose up
dc_stop: ## Docker環境の停止
	docker-compose -f .devcontainer/compose.yaml stop
dc_in: ## Docker環境を立ち上げた後にコンテナの中に入る
	docker exec -it open-dao-front-dev /bin/sh
build_prod: ## 本番用のコンテナをbuildする
	docker build -t front-prod:latest .
run_prod: ## 本番用のコンテナをdocker runする
	docker run -p 3010:3000 --name front-prod -e WORKERS=4 front-prod:latest
stop_prod: ## 本番用のコンテナを停止する
	docker stop front-prod
rm_prod: ## 本番用のコンテナを削除する
	docker rm -f front-prod