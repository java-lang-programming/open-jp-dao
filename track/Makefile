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
dc_stop: ## Docker環境の停止
	docker-compose -f .devcontainer/compose.yaml stop
dc_in: ## Docker環境を立ち上げた後にコンテナの中に入る
	docker exec -it devcontainer-wevb3-rails-dev-app-1 /bin/sh
## DB操作 ##
db_reset: ## データベースリセット
	RAILS_ENV=development bundle exec rails db:reset
db_migrate: ## データベースmigrate
	bundle exec rails db:migrate
db_seed: ## データベースにseed投入
	bundle exec rails db:seed
## gemの管理 ##
bundle_install: ## bundle install
	bundle config set frozen false
	bundle config set --local path 'vendor/bundle'
	bundle install
	bundle clean --force
bundle_install_production: ## bundle install production
	bundle config set frozen false
	bundle config set --local path 'vendor/bundle'
	bundle install --without test development
outdated: ## outdated gemの表示
	bundle outdated
## rails操作 ##
rails_info: ## railsの情報
	bundle exec rails about
log_clear: ## ログ削除
	bundle exec rails log:clear
remove_pid: ## プロセスIDファイル削除
	rm -f tmp/pids/server.pid
brakeman: ## brakeman実行
	bundle exec brakeman
rubocop: ## rubocopを実行
	bundle exec rubocop
rubocop_auto_correct: ## rubocopでコードを自動修正
	bundle exec rubocop --auto-correct
zeitwerk_check: ## zeitwerkモードが有効であることを確認
	bundle exec rails zeitwerk:check
zeitwerk_check_prod: ## zeitwerkモードが有効であることを本番環境で確認
	RAILS_ENV=production bundle exec rails zeitwerk:check
yjit_enabled: ## YJITが有効であることを確認
	bundle exec rails r 'p RubyVM::YJIT.enabled?'
steep_check: ## 型チェック
	bundle exec steep check
ci: ## CIを走らせる
	@echo "##### run rubocop #####"
	make rubocop
	@echo "##### run rubocop auto correct #####"
	make rubocop_auto_correct
	@echo "##### run brakeman #####"
	make brakeman
	@echo "##### run zeitwerk_check #####"
	make zeitwerk_check
	@echo "##### run zeitwerk_check_prod #####"
	make zeitwerk_check_prod
	@echo "##### run yjit_enabled #####"
	make yjit_enabled
launch_dev: ## railsを開発環境で立ち上げ
	make log_clear
	make remove_pid
	make db_reset
	SOLID_QUEUE_IN_PUMA=1 RAILS_ENV=development bundle exec rails server -b 0.0.0.0
launch_prod: ## railsを本番環境で立ち上げ
	make log_clear
	make dc_rm_pid
	RAILS_ENV=production bundle exec rails db:reset
	SOLID_QUEUE_IN_PUMA=1 RAILS_ENV=production bundle exec rails server -b 0.0.0.0
solid_queue_start: ## solid_queueを立ち上げる
	bundle exec rake solid_queue:start
rspec: ## rspec実行
	bundle exec rspec spec --backtrace
## sqlite操作 ##
sqlite3_open: ## DBを開く
	sqlite3 storage/development.sqlite3
sqlite3_queue_open: ## queueのDBを開く
	sqlite3 storage/development_queue.sqlite3
sqlite3_chmod: ## dbのchmod
	chmod 777 storage/development.sqlite3
sqlite3_queue: ## queueのchmod
	chmod 777 storage/development_queue.sqlite3
