SRC = decentralized/*
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
launch_dev_server:
	uvicorn main:app --reload --host=0.0.0.0
launch_pro_server:
	uvicorn main:app --host=0.0.0.0 &
lib_show:
	poetry show
outdated:
	poetry show --outdated
library_update:
	poetry update