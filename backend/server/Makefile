SRC = decentralized/*
TEST = tests/*
format:
	poetry run black $(SRC)
	poetry run ruff format $(SRC)
lint:
	poetry run ruff check $(SRC) --fix
code_formatting:
	make format
	make lint
