class LedgerItem < ApplicationRecord
  enum :kind, { account_item: 1, drawings: 2 }
end
