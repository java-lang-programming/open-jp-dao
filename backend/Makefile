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
	docker-compose -f .devcontainer/compose.yaml up
dc_stop: ## Docker環境の停
	docker-compose -f .devcontainer/compose.yaml stop
# コンテナに入る
in_cont: ## Docker環境を立ち上げた後にコンテナの中に入る
	docker exec -it open-jp-dao-python-server-dev /bin/sh
