class CsvLedgerItem < ApplicationRecord
  # 完全一致false
  EXACT_MATCH_FALSE = 0
  # 完全一致true
  EXACT_MATCH_TRUE = 1
  # 各親テーブルへの所属
  belongs_to :ledger_item
  belongs_to :csv

  def exact_match?
    exact_match == EXACT_MATCH_TRUE
  end
end
