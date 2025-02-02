class ImportFile < ApplicationRecord
  enum :status, { ready: 1, in_progress: 2, failure: 8, completed: 9 }
  belongs_to :address
  belongs_to :job

  has_one_attached :file

  # TODO 将来的にはjobによって切り分ける
  def make_csvs_dollar_yens_transactions
    preload_records =  { address: address, transaction_types: address.transaction_types }
    csvs = []
    file.open do |file|
      row_num = 0
      CSV.foreach(file.open) do |row|
        row_num = row_num + 1
        next if row_num == 1
        csv = Files::DollarYenTransactionDepositCsv.new(address: address, row_num: row_num, row: row, preload_records: preload_records)
        csvs << csv
      end
    end
    csvs
  end
end
