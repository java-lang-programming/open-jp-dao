class DollarYenTransaction < ApplicationRecord
  belongs_to :transaction_type
  belongs_to :address

  scope :latest_date, ->(target_date, adddress_id) { where("date <= ?", target_date).where("address_id = ?", adddress_id).order("id").first }

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
      false
    end
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

  def calculate_withdrawal_en
    raise StandardError, "error!" unless transaction_type.withdrawal?
    previous_dollar_yen_transactions = find_previous_dollar_yen_transactions
    raise StandardError, "預入データが存在しない場合、払出データは計算できません" unless previous_dollar_yen_transactions.present?
    BigDecimal(withdrawal_quantity) * BigDecimal(previous_dollar_yen_transactions.balance_rate)
  end

  def calculate_exchange_difference(withdrawal_en:)
    BigDecimal(exchange_en) - BigDecimal(withdrawal_en)
  end

  # 残帳簿価格 数量米ドルの計算
  def calculate_balance_quantity(previous_dollar_yen_transactions: nil)
    if transaction_type.deposit?
      unless previous_dollar_yen_transactions.present?
        previous_dollar_yen_transactions = find_previous_dollar_yen_transactions
        # 初回(引数の前データもDBの前データもない)
        return BigDecimal(deposit_quantity) unless previous_dollar_yen_transactions.present?
      end
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
  def calculate_balance_en(previous_dollar_yen_transactions: nil)
    if transaction_type.deposit?
      unless previous_dollar_yen_transactions.present?
        previous_dollar_yen_transactions = find_previous_dollar_yen_transactions
        return calculate_deposit_en unless previous_dollar_yen_transactions.present?
      end
      BigDecimal(previous_dollar_yen_transactions.balance_en) + calculate_deposit_en
    elsif transaction_type.withdrawal?
      unless previous_dollar_yen_transactions.present?
        previous_dollar_yen_transactions = find_previous_dollar_yen_transactions
        raise StandardError, "error!" unless previous_dollar_yen_transactions.present?
      end
      BigDecimal(previous_dollar_yen_transactions.balance_en) - calculate_withdrawal_en
    end
  end

  # 属性データを作成
  def make_data
    att_data_h = {}
    en = calculate_deposit_en if deposit?
    att_data_h = att_data_h.merge({ deposit_en: en })
    withdrawal_rate = calculate_withdrawal_rate if withdrawal?
    att_data_h = att_data_h.merge({ withdrawal_rate: withdrawal_rate })
    balance_quantity = dyt.calculate_balance_quantity
    att_data_h = att_data_h.merge({ balance_quantity: balance_quantity })
    att_data_h
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

  def find_previous_dollar_yen_transactions
    DollarYenTransaction.latest_date(date, address_id)
  end
end
