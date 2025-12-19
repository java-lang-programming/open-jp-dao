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
dev: ## 立ち上げる
	pnpm dev
lint: ## build前までに修正
	pnpm lint
typecheck:
	pnpm lint