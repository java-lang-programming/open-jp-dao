FROM python:3.13.3-bullseye as builder

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app/

COPY ./server/pyproject.toml ./server/poetry.lock* ./

# poetryをinstallしてpoetryの設定をする(venv のファイルをプロジェクトディレクトリの下には置かない、並行installをしない、venv を作らずグローバルにパッケージをインストール)
RUN pip install poetry \
  && poetry config virtualenvs.in-project false && poetry config installer.parallel false && poetry config virtualenvs.create false && poetry install --no-root

EXPOSE 8080

