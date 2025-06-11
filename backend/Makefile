.PHONY: dc_build dc_up dc_stop in_cont dc_dev
dc_build:
	docker-compose -f .devcontainer/compose.yaml build
dc_up:
	docker-compose -f .devcontainer/compose.yaml up
dc_stop:
	docker-compose -f .devcontainer/compose.yaml stop
# コンテナに入る
in_cont:
	docker exec -it open-jp-dao-python-server-dev /bin/sh
