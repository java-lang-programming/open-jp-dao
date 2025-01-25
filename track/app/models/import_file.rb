class ImportFile < ApplicationRecord
  enum :status, { ready: 1, in_progress: 2, failure: 8, completed: 9 }
  belongs_to :address
  belongs_to :job

  has_one_attached :file

  # validateはなし
  def make_csvs_dollar_yens_transactions
    preload_records =  { address: address, transaction_types: TransactionType.where(address_id: address.id) }
    csvs = []
    CSV.foreach(file) do |row|
      row_num = row_num + 1
      next if row_num == 1
      csv = Files::DollarYenTransactionDepositCsv.new(address: target_address, row_num: row_num, row: row, preload_records: preload_records)
      csvs << csv
    end
    csvs
  end
end
