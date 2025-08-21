module Views
  class Nav
    attr_accessor :kind

    def initialize(kind: 1)
      @kind = kind
    end

    def list
      [
        { name: "為替差益", path: foreign_exchange_gain_dollar_yen_transactions_path },
        { name: "ドル円外貨預金元帳", path: dollar_yen_transactions_path },
        { name: "取引種類", path: transaction_types_path }
      ]
    end
  end
end
