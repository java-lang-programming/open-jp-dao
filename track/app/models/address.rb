class Address < ApplicationRecord
  enum :kind, { ethereum: 1, solana: 2 }
  has_many :transaction_types, dependent: :destroy
  has_many :dollar_yen_transactions, dependent: :destroy
  has_many :sessions, dependent: :destroy
  has_many :import_files, dependent: :destroy

  validates :address, presence: true

  def generate_dollar_yen_transactions_csv_import_file(output_csv_file_path:)
    csv_data = generate_dollar_yen_transactions_csv_import_data
    File.write(output_csv_file_path, csv_data)
  end

  def generate_dollar_yen_transactions_csv_import_data
    csv_data = CSV.generate do |csv|
      column_names = Files::DollarYenTransactionDepositCsv::COLUMN_NAMES
      csv << column_names

      dollar_yen_transactions.order("date").order("transaction_type_id").each do |dollar_yen_transaction|
        csv << dollar_yen_transaction.to_csv_import_format
      end
    end.chomp
  end

  def generate_dollar_yen_transactions_csv_export_import_file(output_csv_file_path:)
    csv_data = generate_dollar_yen_transactions_csv_export_import_data
    File.write(output_csv_file_path, csv_data)
  end

  def generate_dollar_yen_transactions_csv_export_import_data
    csv_data = CSV.generate do |csv|
      column_names = []
      csv << DollarYenTransaction::EXPORT_CSV_COLUMN_NAMES

      dollar_yen_transactions.order("date").order("transaction_type_id").each do |dollar_yen_transaction|
        csv << dollar_yen_transaction.to_csv_export_format
      end
    end.chomp
  end

  # ファイル名を作成
  def make_file_name
    "#{address}_#{Time.now.strftime("%Y%m%d%H%M%S")}.csv"
  end

  # target_dateにより影響を受ける再計算が必要な取引データ一覧
  def recalculation_need_dollar_yen_transactions(target_date:)
    dollar_yen_transactions.where("date >= ?", target_date)
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
