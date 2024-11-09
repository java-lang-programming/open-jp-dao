class DollarYenTransaction < ApplicationRecord
  belongs_to :transaction_type
  belongs_to :address

  scope :latest_date, ->(target_date) { where("date <= ?", target_date).order("id").first }

  # validates :date, presence: true
  # https://railsguides.jp/active_record_validations.html#%E3%82%AB%E3%82%B9%E3%82%BF%E3%83%A0%E3%83%A1%E3%82%BD%E3%83%83%E3%83%89
  # validate :date_valid
  validates :deposit_rate, numericality: true, if: :deposit?
  validates :deposit_quantity, numericality: true, if: :deposit?
  validates :withdrawal_quantity, numericality: true, if: :withdrawal?
  validates :exchange_en, numericality: true, if: :withdrawal?

  def deposit?
    transaction_type.deposit?
  end

  def withdrawal?
    transaction_type.withdrawal?
  end

  def date_valid(target_date:)
    begin
      Date.parse(target_date)
      true
    rescue => e
      puts "ここ"
      false
    end
  end

  # 円換算(小数点切り捨て)
  def calculate_deposit_en
    (BigDecimal(deposit_rate) * BigDecimal(deposit_quantity)).floor
  end

  def calculate_withdrawal_rate(target_date:)
    raise StandardError, "error!" unless transaction_type.withdrawal?
    latest_dollar_yen_transactions = DollarYenTransaction.latest_date(target_date)
    raise StandardError, "error!" unless latest_dollar_yen_transactions.present?
    BigDecimal(latest_dollar_yen_transactions.balance_rate)
  end

  def calculate_withdrawal_en(target_date:)
    raise StandardError, "error!" unless transaction_type.withdrawal?
    latest_dollar_yen_transactions = DollarYenTransaction.latest_date(target_date)
    raise StandardError, "error!" unless latest_dollar_yen_transactions.present?
    BigDecimal(withdrawal_quantity) * BigDecimal(latest_dollar_yen_transactions.balance_rate)
  end

  def calculate_exchange_difference(withdrawal_en:)
    BigDecimal(exchange_en) - BigDecimal(withdrawal_en)
  end

  # 残帳簿価格 数量米ドルの計算
  def calculate_balance_quantity(target_date:)
    # ターゲット日の最新日の情報を取得
    latest_dollar_yen_transactions = DollarYenTransaction.latest_date(target_date)
    if transaction_type.deposit?
      # 残帳簿価格米ドル
      return BigDecimal(deposit_quantity) unless latest_dollar_yen_transactions.present?
      BigDecimal(latest_dollar_yen_transactions.balance_quantity) + BigDecimal(deposit_quantity)
    elsif transaction_type.withdrawal?
      raise StandardError, "error!" unless latest_dollar_yen_transactions.present?
      BigDecimal(latest_dollar_yen_transactions.balance_quantity) - BigDecimal(withdrawal_quantity)
    end
  end

  def calculate_balance_rate(balance_quantity:, balance_en:)
    BigDecimal(balance_en) / BigDecimal(balance_quantity)
  end

  def calculate_balance_en(target_date:)
    # ターゲット日の最新日の情報を取得
    latest_dollar_yen_transactions = DollarYenTransaction.latest_date(target_date)
    if transaction_type.deposit?
      # 残帳簿価格円
      return calculate_deposit_en unless latest_dollar_yen_transactions.present?
      BigDecimal(latest_dollar_yen_transactions.balance_en) + calculate_deposit_en
    elsif transaction_type.withdrawal?
      raise StandardError, "error!" unless latest_dollar_yen_transactions.present?
      BigDecimal(latest_dollar_yen_transactions.balance_en) - calculate_withdrawal_en(target_date: target_date)
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
end
