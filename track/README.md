# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

##　コンテナ起動

```
make dc_up
```

##　コンテナに入る

```
docker exec -it devcontainer_wevb3-rails-dev-app_1 /bin/sh
```

## temp

curl -X POST -F "file=@/Users/masayasuzuki/workplace/study/open-jp-dao/track/test.csv" http://localhost/3000/apis/dollaryen/transactions/csv_upload

curl -X POST -F "file=@/Users/masayasuzuki/workplace/study/open-jp-dao/track/test_error_deposit_csv.csv" http://localhost:3000/apis/dollaryen/transactions/csv_upload

curl  'http://localhost:3000/apis/dollaryen/transactions'

bundle exec rails generate controller apis/dollaryen/foreigne_exchange_gain
bundle exec rails destroy controller apis/dollaryen/foreigne_exchange_gain