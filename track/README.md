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
rails-new --devcontainer --database=sqlite3
docker exec -it wanwan-create /bin/sh
docker exec -it devcontainer-wevb3-rails-dev-app-1 /bin/sh
```

## temp

curl -X POST -F "file=@/Users/masayasuzuki/workplace/study/open-jp-dao/track/test.csv" http://localhost/3000/apis/dollaryen/transactions/csv_upload

curl -X POST -F "file=@/Users/masayasuzuki/workplace/study/open-jp-dao/track/test_error_deposit_csv.csv" http://localhost:3000/apis/dollaryen/transactions/csv_upload

curl -X POST -F "file=@/Users/masayasuzuki/workplace/study/open-jp-dao/track/dollar_yens.csv" -H "Content-Type: application/json" -d '{"address":"0x00001E868c62FA205d38BeBaB7B903322A4CC89D"}' http://localhost:3000/apis/dollar_yens/csv_import

curl -X POST -F "file=@/Users/masayasuzuki/workplace/study/open-jp-dao/track/dollar_yens.csv" http://localhost:3000/apis/dollar_yens/csv_import


-F "file=@/Users/masayasuzuki/workplace/study/open-jp-dao/track/test_error_deposit_csv.csv"

curl -X POST http://localhost:3000/session

curl  'http://localhost:3000/apis/dollaryen/transactions'

bundle exec rails generate controller apis/transaction_types
bundle exec rails generate controller apis/notifications index
bundle exec rails destroy controller apis/dollar_yen
bundle exec rails destroy controller apis/dollaryen/foreigne_exchange_gain
bundle exec rails generate model DollarYen date:date:uniq dollar_yen_nakane:
bundle exec rails generate model ApplicationError environment_id: integer log:text


bundle exec rails generate job dollar_yen_csv_import --queue csv
bundle exec rails generate job dollar_yen_transactions_csv_import --queue csv

DollarYenTransactionDepositCsv

bundle exec rails generate model Job job_name:string summary:text
bundle exec rails generate model Notification message:string start_date:timestamp end_date:timestamp
bundle exec rails generate model LedgerItem

ドル円のcsvをimportします
ドル円取引のcsvをimportします

 
bundle exec  rails generate model LedgerItem name:string kind:integer summary:string deleted_at:datetime


次

sessionとトランザクションでviewを試す。

bundle exec rails generate controller dollar_yen_transactions
bundle exec rails generate controller transaction_types
bundle exec rails generate controller foreign_exchange_gains
bundle exec rails generate controller import_files
bundle exec rails generate controller ledger index
bundle exec rails generate controller top

      create  app/controllers/ledger_controller.rb
       route  get "ledger/index"
      invoke  tailwindcss
      create    app/views/ledger
      create    app/views/ledger/index.html.erb
      invoke  rspec
      create    spec/requests/ledger_spec.rb
      create    spec/views/ledger
      create    spec/views/ledger/index.html.tailwindcss_spec.rb
      invoke  helper
      create    app/helpers/ledger_helper.rb
      invoke    rspec
      create      spec/helpers/ledger_helper_spec.rb
Coverage report generated for RSpec to /usr/src/app/coverage.
