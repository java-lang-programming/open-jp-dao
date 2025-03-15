module Files
  class DollarYenTransactionExportCsv
    COLUMN_DATE_INDEX = 0
    COLUMN_TRANSACTION_TYPE_INDEX = 1
    COLUMN_DEPOSIT_QUANTITY_INDEX = 2
    COLUMN_DEPOSIT_RATE_INDEX = 3
    COLUMN_DEPOSIT_EN_INDEX = 4
    COLUMN_WITHDRAWAL_QUANTITY_INDEX = 5
    COLUMN_WITHDRAWAL_RATE_INDEX = 6
    COLUMN_WITHDRAWAL_EN_INDEX = 7
    COLUMN_BALANCE_QUANTITY_INDEX = 8
    COLUMN_BALANCE_RATE_INDEX = 9
    COLUMN_BALANCE_EN_INDEX = 10

    # date  transaction_type  deposit_quantity  deposit_rate  withdrawal_quantity exchange_en
    COLUMN_NAMES = %i[
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

    # cache transaction_typeが必要
    attr_accessor :address, :row_num, :date, :transaction_type_name, :deposit_quantity, :deposit_rate, :deposit_en, :withdrawal_quantity, :withdrawal_rate, :withdrawal_en, :balance_quantity, :balance_rate, :balance_en

    def initialize(row:)
      @date = row[COLUMN_DATE_INDEX]
      @transaction_type_name = row[COLUMN_TRANSACTION_TYPE_INDEX]
      @deposit_quantity = row[COLUMN_DEPOSIT_QUANTITY_INDEX]
      @deposit_rate = row[COLUMN_DEPOSIT_RATE_INDEX]
      @deposit_en = row[COLUMN_DEPOSIT_EN_INDEX]
      @withdrawal_quantity = row[COLUMN_WITHDRAWAL_QUANTITY_INDEX]
      @withdrawal_rate = row[COLUMN_WITHDRAWAL_RATE_INDEX]
      @withdrawal_en = row[COLUMN_WITHDRAWAL_EN_INDEX]
      @balance_quantity = row[COLUMN_BALANCE_QUANTITY_INDEX]
      @balance_rate = row[COLUMN_BALANCE_RATE_INDEX]
      @balance_en = row[COLUMN_BALANCE_EN_INDEX]
    end

    # dateを差し替える
    def replace_date(date:)
      @date = date
    end

    def replace_transaction_type_name(transaction_type_name:)
      @transaction_type_name = transaction_type_name
    end

    def line_to_s
      @date + "," + @transaction_type_name + "," + @deposit_quantity + "," + @deposit_rate  + "," + @deposit_en + "," + output_withdrawal_quantity + "," + output_withdrawal_rate + "," + output_withdrawal_en + "," + @balance_quantity + "," + @balance_rate + "," + @balance_en
    end

    def output_withdrawal_quantity
      return "" unless @withdrawal_quantity.present?
      @withdrawal_quantity
    end

    def output_withdrawal_rate
      return "" unless @withdrawal_rate.present?
      @withdrawal_rate
    end

    def output_withdrawal_en
      return "" unless @withdrawal_en.present?
      @withdrawal_en
    end
  end
end
