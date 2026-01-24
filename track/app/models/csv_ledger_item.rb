class CsvLedgerItem < ApplicationRecord
  EXACT_MATCH_TRUE = 1
  # 各親テーブルへの所属
  belongs_to :ledger_item
  belongs_to :csv
end
