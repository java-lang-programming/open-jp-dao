class Address < ApplicationRecord
  enum :kind, { ethereum: 1, solana: 2 }
  has_many :transaction_types, dependent: :destroy
  has_many :dollar_yen_transactions, dependent: :destroy
  has_many :sessions, dependent: :destroy

  validates :address, presence: true

  def generate_dollar_yen_transactions_csv_import_file(output_csv_file_path:)
    csv_data = CSV.generate do |csv|
      column_names = Files::DollarYenTransactionDepositCsv::COLUMN_NAMES
      csv << column_names

      dollar_yen_transactions.order("date").order("transaction_type_id").each do |dollar_yen_transaction|
        csv << dollar_yen_transaction.to_csv_import_format
      end
    end.chomp
    # ファイルのパスとcsvデータを指定して、csvファイル作成
    File.write(output_csv_file_path, csv_data)
  end

  def generate_dollar_yen_transactions_csv_export_import_file(output_csv_file_path:)
    csv_data = CSV.generate do |csv|
      column_names = []
      csv << DollarYenTransaction::EXPORT_CSV_COLUMN_NAMES

      dollar_yen_transactions.order("date").order("transaction_type_id").each do |dollar_yen_transaction|
        csv << dollar_yen_transaction.to_csv_export_format
      end
    end.chomp
    # ファイルのパスとcsvデータを指定して、csvファイル作成
    File.write(output_csv_file_path, csv_data)
  end

  class << self
    def kind_errors(kind: nil)
      errors = []
      unless kind.present?
        errors << "kindは必須入力です"
      else
        unless Address.kinds.values.include?(kind.to_i)
          errors << "kindが不正な値です"
        end
      end
      errors
    end
  end
end
