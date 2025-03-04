class DollarYenTransaction < ApplicationRecord
  belongs_to :transaction_type
  belongs_to :address

  scope :find_by_date_and_transaction_type_id, ->(target_date, transaction_type_id) { where(date: target_date).where(transaction_type_id: transaction_type_id) }

  # validates :date, presence: true
  # https://railsguides.jp/active_record_validations.html#%E3%82%AB%E3%82%B9%E3%82%BF%E3%83%A0%E3%83%A1%E3%82%BD%E3%83%83%E3%83%89
  # validate :date_valid
  validates :deposit_rate, numericality: true, if: :deposit?
  validates :deposit_quantity, numericality: true, if: :deposit?
  validates :withdrawal_quantity, numericality: true, if: :withdrawal?
  validates :exchange_en, numericality: true, if: :withdrawal?

  # 取引日   数量米ドル レート 円換算 数量米ドル レート 円換算 数量米ドル レート 円換算
  EXPORT_CSV_COLUMN_NAMES = %i[
    date
    transaction_type
    deposit_quantity
    deposit_rate
    deposit_en
    withdrawal_quantity
    withdrawal_rate
    withdrawal_en
    balance_quantity
    balance_rate
    balance_en
  ]

  def deposit?
    transaction_type.deposit?
  end

  def withdrawal?
    transaction_type.withdrawal?
  end

  # 円換算(小数点切り捨て)
  def calculate_deposit_en
    (BigDecimal(deposit_rate) * BigDecimal(deposit_quantity)).floor
  end

  def calculate_withdrawal_rate(previous_dollar_yen_transactions: nil)
    raise StandardError, "error!" unless transaction_type.withdrawal?
    unless previous_dollar_yen_transactions.present?
      previous_dollar_yen_transactions = find_previous_dollar_yen_transactions
    end
    raise StandardError, "預入データが存在しない場合、払出データは計算できません" unless previous_dollar_yen_transactions.present?
    BigDecimal(previous_dollar_yen_transactions.balance_rate)
  end

  def calculate_withdrawal_en(previous_dollar_yen_transactions: nil)
    raise StandardError, "error!" unless transaction_type.withdrawal?
    unless previous_dollar_yen_transactions.present?
      previous_dollar_yen_transactions = find_previous_dollar_yen_transactions
    end
    raise StandardError, "預入データが存在しない場合、払出データは計算できません" unless previous_dollar_yen_transactions.present?
    BigDecimal(withdrawal_quantity) * BigDecimal(previous_dollar_yen_transactions.balance_rate)
  end

  def calculate_exchange_difference(withdrawal_en:)
    BigDecimal(exchange_en) - BigDecimal(withdrawal_en)
  end

  # 残帳簿価格 数量米ドルの計算
  #
  # @param previous_dollar_yen_transactions [Files::DollarYenTransactionDepositCsv or nil] csvのファイルオブジェクト
  # @return [BigDecimal] 数量米ドル
  def calculate_balance_quantity(previous_dollar_yen_transactions: nil)
    if transaction_type.deposit?
      return previous_balance_quantity unless previous_dollar_yen_transactions.present?
      BigDecimal(previous_dollar_yen_transactions.balance_quantity) + BigDecimal(deposit_quantity)
    elsif transaction_type.withdrawal?
      unless previous_dollar_yen_transactions.present?
        previous_dollar_yen_transactions = find_previous_dollar_yen_transactions
        raise StandardError, "error!" unless previous_dollar_yen_transactions.present?
      end
      BigDecimal(previous_dollar_yen_transactions.balance_quantity) - BigDecimal(withdrawal_quantity)
    end
  end

  def calculate_balance_rate(balance_quantity:, balance_en:)
    BigDecimal(balance_en) / BigDecimal(balance_quantity)
  end

  # 残帳簿価格 残高円の計算
  #
  # @param previous_dollar_yen_transactions [Files::DollarYenTransactionDepositCsv or nil] csvのファイルオブジェクト
  # @return [BigDecimal]  残高円
  def calculate_balance_en(previous_dollar_yen_transactions: nil)
    if transaction_type.deposit?
      unless previous_dollar_yen_transactions.present?
        return previous_balance_en unless previous_dollar_yen_transactions.present?
      end
      BigDecimal(previous_dollar_yen_transactions.balance_en) + calculate_deposit_en
    elsif transaction_type.withdrawal?
      unless previous_dollar_yen_transactions.present?
        previous_dollar_yen_transactions = find_previous_dollar_yen_transactions
        raise StandardError, "error!" unless previous_dollar_yen_transactions.present?
      end
      BigDecimal(previous_dollar_yen_transactions.balance_en) - calculate_withdrawal_en(previous_dollar_yen_transactions: previous_dollar_yen_transactions)
    end
  end

  # 為替差益計算
  def self.calculate_foreign_exchange_gain(start_date:, end_date:)
    transactions = DollarYenTransaction.where(date: [ start_date..end_date ])
    # 払出トランザクションを取得
    withdrawal_transactions = transactions.select do |transaction|
      transaction.withdrawal?
    end

    reuslt = withdrawal_transactions.inject(0) do |result, item|
      result + BigDecimal(item.exchange_difference)
    end

    { sum: reuslt, withdrawal_transactions: withdrawal_transactions }
  end

  # csv importを作成する
  # これはaddressクラスかな。。。
  def self.make_csv_import_file(address:, csv_file_path:)
    csv_data = CSV.generate do |csv|
      column_names = Files::DollarYenTransactionDepositCsv::COLUMN_NAMES
      csv << column_names

      address.dollar_yen_transactions.order("date").order("date").each do |dollar_yen_transaction|
        csv << dollar_yen_transaction.to_csv_import_format
      end
    end.chomp
    # ファイルのパスとcsvデータを指定して、csvファイル作成
    File.write(csv_file_path, csv_data)
  end

  # 　同一日付のデータがあった場合の試験
  def find_previous_dollar_yen_transactions
    address.dollar_yen_transactions.where("date < ?", date).order("id").first
  end

  def deposit_rate_on_screen
    return BigDecimal(deposit_rate).floor(2).to_f if deposit_rate.present?
    nil
  end

  def deposit_quantity_on_screen
    return BigDecimal(deposit_quantity).floor(2).to_f if deposit_quantity.present?
    nil
  end

  # @return [Integer|nil] 画面で表示するdeposit 円換算
  #
  # deposit_enを表示する。小数点以下の数を切り捨てて整数にする。データがない場合はnil
  #
  def deposit_en_screen
    return BigDecimal(deposit_en).floor(0).to_i if deposit_en.present?
    nil
  end

  # @return [float|nil] 画面で表示するwithdrawal_rate
  #
  # withdrawal_rateを表示する。データがない場合はnil
  #
  def withdrawal_rate_on_screen
    return BigDecimal(withdrawal_rate).floor(2).to_f if withdrawal_rate.present?
    nil
  end

  # @return [float|nil] 画面で表示するwithdrawal_quantity
  #
  # withdrawal_quantityを表示する。データがない場合はnil
  #
  def withdrawal_quantity_on_screen
    return BigDecimal(withdrawal_quantity).floor(2).to_f if withdrawal_quantity.present?
    nil
  end

  def withdrawal_en_on_screen
    return BigDecimal(withdrawal_en).floor(2).to_f if withdrawal_en.present?
    nil
  end

  def exchange_en_on_screen
    return BigDecimal(exchange_en).floor(2).to_f if exchange_en.present?
    nil
  end

  def exchange_difference_on_screen
    return BigDecimal(exchange_difference).floor(2).to_f if exchange_difference.present?
    nil
  end

  def balance_rate_on_screen
    return BigDecimal(balance_rate).floor(2).to_f if balance_rate.present?
    nil
  end

  def balance_quantity_on_screen
    return BigDecimal(balance_quantity).floor(2).to_f if balance_quantity.present?
    nil
  end

  # @return [Integer|nil] 残帳簿価格 円換算
  # 小数点以下の数を切り捨てて整数にする
  def balance_en_on_screen
    return BigDecimal(balance_en).floor(0).to_i if balance_en.present?
    nil
  end

  # csv import用のデータに変換
  # date,transaction_type,deposit_quantity,deposit_rate,withdrawal_quantity,exchange_en
  def to_csv_import_format
    line_data = []
    # date
    line_data << date.strftime("%Y/%m/%d")
    # transaction_type
    line_data << transaction_type.name

    if deposit_quantity.present?
      line_data << deposit_quantity.to_s
    else
      line_data << nil
    end

    if deposit_rate.present?
      line_data << deposit_rate.to_s
    else
      line_data << nil
    end

    if withdrawal_quantity.present?
      line_data << withdrawal_quantity.to_i.to_s
    else
      line_data << nil
    end

    if exchange_en.present?
      line_data << exchange_en.to_i.to_s
    else
      line_data << nil
    end
    line_data
  end

  # csv export用のデータに変換
  # date,transaction_type,deposit_quantity,deposit_rate,deposit_en
  def to_csv_export_format
    line_data = []
    # date
    line_data << date.strftime("%Y/%m/%d")
    # transaction_type
    line_data << transaction_type.name

    if deposit_quantity.present?
      line_data << deposit_quantity.to_f
    else
      line_data << nil
    end

    if deposit_rate.present?
      line_data << deposit_rate.to_f
    else
      line_data << nil
    end

    if deposit_en.present?
      line_data << deposit_en.to_i
    else
      line_data << nil
    end

    if withdrawal_quantity.present?
      line_data << withdrawal_quantity.to_f
    else
      line_data << nil
    end

    if withdrawal_rate.present?
      line_data << withdrawal_rate.to_f
    else
      line_data << nil
    end

    if withdrawal_en.present?
      line_data << withdrawal_en.to_f
    else
      line_data << nil
    end

    line_data << balance_quantity.to_f
    line_data << balance_rate.to_f
    line_data << balance_en.to_f

    line_data
  end

  # Files::DollarYenTransactionDepositCsvオブジェクトに変換します
  #
  # @param row_num [integer] csvのrow
  # @param preload_records [Hash[address, transaction_types]] 何度も使うオブジェクト
  # @return [Files::DollarYenTransactionDepositCsv] Files::DollarYenTransactionDepositCsvオブジェクト
  def to_files_dollar_yen_transaction_csv(row_num:, preload_records:)
    Files::DollarYenTransactionDepositCsv.new(address: preload_records[:address], row_num: row_num, row: to_csv_import_format, preload_records: preload_records)
  end

  # リクエストの処理
  # def re(request)

  # end

  # 更新用のdollar_yen_transactions一覧を作成する
  #
  # @return [Array[DollarYenTransaction]] DollarYenTransaction一覧オブジェクト
  def generate_upsert_dollar_yens_transactions
    # 共通化する
    preload_records = { address: address, transaction_types: address.transaction_types }
    # 再計算が必要なデータ
    recalculation_need_dollar_yen_transactions = address.recalculation_need_dollar_yen_transactions(target_date: date)

    existing_csvs = recalculation_need_dollar_yen_transactions.map do |dollar_yen_transaction|
      dollar_yen_transaction.to_files_dollar_yen_transaction_csv(row_num: -1, preload_records: preload_records)
    end

    # 今回のcsvと更新が必要な登録済みのデータをmerge
    upsert_csvs = [ to_files_dollar_yen_transaction_csv(row_num: -1, preload_records: preload_records) ].concat(existing_csvs)
    # 再計算
    Files::DollarYenTransactionDepositCsv.make_dollar_yen_transactions(csvs: upsert_csvs)
  end

  private

    # 残帳簿価格で呼び出し 以前のデータをデータベース経由で数量米ドルを取得する
    #
    # @return [BigDecimal] 数量米ドル
    def previous_balance_quantity
      previous_dollar_yen_transactions = find_previous_dollar_yen_transactions
      # 以前のデータがない or 初回
      return BigDecimal(deposit_quantity) unless previous_dollar_yen_transactions.present?
      # 以前のデータがある
      previous_dollar_yen_transactions.balance_quantity + BigDecimal(deposit_quantity)
    end

    # 残帳簿価格で呼び出し 以前のデータをデータベース経由で残高円を取得する
    #
    # @return [BigDecimal] 残高円
    def previous_balance_en
      dollar_yen_transaction = find_previous_dollar_yen_transactions
      # 以前のデータがない or 初回
      return calculate_deposit_en unless dollar_yen_transaction.present?
      # 以前のデータがある
      dollar_yen_transaction.balance_en + calculate_deposit_en
    end
end
