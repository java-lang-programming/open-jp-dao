class Address < ApplicationRecord
  enum :kind, { ethereum: 1, solana: 2 }
  has_many :transaction_types, dependent: :destroy
  has_many :dollar_yen_transactions, dependent: :destroy
  has_many :sessions, dependent: :destroy
  has_many :import_files, dependent: :destroy

  validates :address, presence: true


  class NotFoundDeleteDollarYenTransactionID < StandardError; end

  # matamask形式のaddress表示
  def matamask_format_address
    full_address = address
    full_address[0...7] + "..." + full_address[-5..-1]
  end

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


  # ここから下はconcernに移動
  # @return [Array[DollarYenTransaction]] 作成時に再計算が必要なdollar_yen_transactions
  #
  def recalculation_need_dollar_yen_transactions_create(target_date:)
    dollar_yen_transactions.where("date > ?", target_date).order(date: :asc).order(date: :asc).order(id: :asc)
  end

  # 　@return [Array[DollarYenTransaction]] 削除時に再計算が必要なdollar_yen_transactions
  def recalculation_need_dollar_yen_transactions_delete(target_date:, id: nil)
    raise NotFoundDeleteDollarYenTransactionID unless id.present?
    # 同日データで自分以外の中でidが大きいデータ一覧
    same_day_dollar_yen_transactions = dollar_yen_transactions.where(date: target_date).where.not(id: id).where("id > ?", id).order(date: :asc).order(id: :asc)
    # 日付より先のデータ
    next_dollar_yen_transactions = dollar_yen_transactions.where("date > ?", target_date).order(date: :asc).order(id: :asc)
    dollar_yen_transactions = []
    same_day_dollar_yen_transactions.each do |t|
      dollar_yen_transactions << t
    end
    next_dollar_yen_transactions.each do |t|
      dollar_yen_transactions << t
    end
    dollar_yen_transactions
  end

  # 更新時に再計算が必要なdollar_yen_transactions
  #
  # @param target_date [Date] 日付
  # @param id [Integer] 更新対象のid
  # @return [Array[DollarYenTransaction]] 更新時に再計算が必要なdollar_yen_transactions
  def recalculation_need_dollar_yen_transactions_update(target_date:, id: nil)
    recalculation_need_dollar_yen_transactions_delete(target_date: target_date, id: id)
  end

  # 作成時に再計算対象の1つ手前のdollar_yen_transactionを返す
  #
  # @return [DollarYenTransaction | nil] 作成時に再計算対象の1つ手前のdollar_yen_transactions
  def base_dollar_yen_transaction_create(target_date:)
    dollar_yen_transactions.where("date <= ?", target_date).order(date: :asc).order(date: :asc).order(id: :asc).last
  end

  # 削除時に再計算対象の1つ手前のdollar_yen_transactionを返す
  #
  # @param target_date [Date] 日付
  # @param id [Integer] 削除対象のid
  # @return [DollarYenTransaction | nil] 削除時に再計算対象の1つ手前のdollar_yen_transactions
  def base_dollar_yen_transaction_delete(target_date:, id:)
    dollar_yen_transactions.where("date <= ?", target_date).where.not(id: id).where("id < ?", id).order(date: :asc).order(id: :asc).last
  end

  # 更新時に再計算対象の1つ手前のdollar_yen_transactionを返す
  #
  # @param target_date [Date] 日付
  # @param id [Integer] 更新対象のid
  # @return [DollarYenTransaction | nil] 更新時に再計算対象の1つ手前のdollar_yen_transactions
  def base_dollar_yen_transaction_update(target_date:, id:)
    base_dollar_yen_transaction_delete(target_date: target_date, id: id)
  end

  # encを取得する
  def fetch_ens(chain_id: 1)
    ChainGate::Repositories::Sessions::Ens.new(
      chain_id: chain_id,
      address: address
    ).fetch
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
