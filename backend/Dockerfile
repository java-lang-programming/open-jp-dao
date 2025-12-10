FROM python:3.13.3-bullseye as builder

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app/

COPY ./server/pyproject.toml ./server/poetry.lock ./

# poetryをinstallしてpoetryの設定をする(venv のファイルをプロジェクトディレクトリの下には置かない、並行installをしない、venv を作らずグローバルにパッケージをインストール)
RUN pip install poetry \
  && poetry config virtualenvs.in-project false && poetry config installer.parallel false && poetry config virtualenvs.create false && poetry install --without dev --no-interaction --no-ansi --no-root

COPY ./server/. .


# CMDをシェル形式で定義する
CMD gunicorn src.main:app \
    --worker-class uvicorn.workers.UvicornWorker \
    --workers ${WORKERS:-2} \
    --bind 0.0.0.0:8000 \
    --access-logfile - \
    --error-logfile -