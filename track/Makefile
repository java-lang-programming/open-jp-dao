.PHONY: dc_build dc_up dc_stop dc_rm_pid dc_dev_with_que dc_dev zeitwerk_check_prod mini_test rubocop rubocop_auto_correct steep_check bundle_install bundle_install_production outdated dev_init
dc_build:
	docker-compose -f .devcontainer/compose.yaml build
dc_up:
	docker-compose -f .devcontainer/compose.yaml up
dc_stop:
	docker-compose -f .devcontainer/compose.yaml stop
dc_rm_pid:
	rm -f tmp/pids/server.pid
dc_dev_with_que:
	make dc_rm_pid
	SOLID_QUEUE_IN_PUMA=1 bundle exec rails server -b 0.0.0.0
dc_dev:
	make log_clear
	make dc_rm_pid
	# ここで環境変数のチェック
	RAILS_ENV=development bundle exec rails db:reset
	SOLID_QUEUE_IN_PUMA=1 RAILS_ENV=development bundle exec rails server -b 0.0.0.0
dc_prod:
	make log_clear
	make dc_rm_pid
	# ここで環境変数のチェック
	RAILS_ENV=production bundle exec rails db:reset
	SOLID_QUEUE_IN_PUMA=1 RAILS_ENV=production bundle exec rails server -b 0.0.0.0
rails_info:
	bundle exec rails about
zeitwerk_check:
	bundle exec rails zeitwerk:check
zeitwerk_check_prod:
	RAILS_ENV=production bundle exec rails zeitwerk:check
brakeman:
	bundle exec brakeman
yjit_enabled:
	bundle exec rails r 'p RubyVM::YJIT.enabled?'
mini_test:
	bundle exec rails test
rubocop:
	bundle exec rubocop
rubocop_auto_correct:
	bundle exec rubocop --auto-correct
steep_check:
	bundle exec steep check
bundle_install:
	bundle config set frozen false
	bundle config set --local path 'vendor/bundle'
	bundle install
bundle_install_production:
	bundle config set frozen false
	bundle config set --local path 'vendor/bundle'
	bundle install --without test development
outdated:
	bundle outdated
migrate:
	bundle exec rails db:migrate
reset:
	bundle exec rails db:reset
rspec:
	bundle exec rspec spec --backtrace
log_clear:
	bundle exec rails log:clear
seed:
	bundle exec rails db:seed
sqlite3_open:
	sqlite3 storage/development.sqlite3
sqlite3_queue_open:
	sqlite3 storage/development_queue.sqlite3
sqlite3_chmod:
	chmod 777 storage/development.sqlite3
sqlite3_queue:
	chmod 777 storage/development_queue.sqlite3
solid_queue_start:
	bundle exec rake solid_queue:start
