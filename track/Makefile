.PHONY: dc_build dc_up dc_stop dc_rm_pid dc_dev mini_test rubocop rubocop_auto_correct install
dc_build:
	docker-compose -f .devcontainer/compose.yaml build
dc_up:
	docker-compose -f .devcontainer/compose.yaml up
dc_stop:
	docker-compose -f .devcontainer/compose.yaml stop
dc_rm_pid:
	rm -f tmp/pids/server.pid
dc_dev:
	make dc_rm_pid
	bundle exec rails server -b 0.0.0.0
rails_info:
	bundle exec rails about
zeitwerk_check:
	bundle exec rails zeitwerk:check
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
install:
	bundle config set --local path 'vendor/bundle'
	bundle install
migrate:
	bundle exec rails db:migrate
rspec:
	bundle exec rspec spec --backtrace
# spec/models/files/
# bundle exec rails generate rspec:model transaction_type