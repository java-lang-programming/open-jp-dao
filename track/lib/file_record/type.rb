module FileRecord
  module Type
    # お金の円をintegerにする
    def money_en_to_integer(value:)
      normalized = value.to_s
                        .delete(",")
                        .gsub(/\A'|'?\Z/, "")

      Integer(normalized)
    end
  end
end
