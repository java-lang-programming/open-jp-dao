RULE_REGEX := ^[a-zA-Z_][a-zA-Z0-9_-]+:
RULE_AND_DESC_REGEX := $(RULE_REGEX).*?## .*$$
EXTRA_COMMENT_REGEX := ^## .* ##$$
.ONESHELL:
.DEFAULT_GOAL := help
.PHONY: help

# INFO: 参考サイト - https://postd.cc/auto-documented-makefile/ https://zenn.dev/loglass/articles/0016-make-makefile
help:
	@grep -E $(RULE_AND_DESC_REGEX) $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

SRC = src/*
TEST = tests/*
format:
	poetry run black $(SRC)
	poetry run ruff format $(SRC)
lint:
	poetry run ruff check $(SRC) --fix
	poetry run ruff check $(TEST) --fix
code_formatting:
	make format
	make lint
unit_test:
	poetry run pytest -s --cache-clear tests/bunsan
	poetry run pytest -s --cache-clear tests/decentralized/requests/solana
	poetry run pytest -s --cache-clear tests/decentralized/responses/
	poetry run pytest -s --cache-clear tests/exceptions/
unit_test_client:
	poetry run pytest -s --cache-clear tests/test_main.py
	poetry run pytest -s --cache-clear tests/test_sessions.py
	poetry run pytest -s --cache-clear tests/test_solana.py
launch_dev_server: ## unicornを開発環境で立ち上げ
	uvicorn src.main:app --reload --host=0.0.0.0
launch_pro_server:
	uvicorn src.main:app --host=0.0.0.0 &
lib_show:
	poetry show
outdated:
	poetry show --outdated
library_update:
	poetry update