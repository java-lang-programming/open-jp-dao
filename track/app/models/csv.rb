class Csv < ApplicationRecord
  # UFJ
  ID_UFJ = 1
  # 中間テーブルとのリレーション
  has_many :csv_ledger_items, dependent: :destroy
  # LedgerItemとの多対多のリレーション
  has_many :ledger_items, through: :csv_ledger_items
end
