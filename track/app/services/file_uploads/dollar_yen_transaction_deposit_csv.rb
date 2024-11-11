  # module Services
  module FileUploads
    class DollarYenTransactionDepositCsv
      attr_accessor :file

      def initialize(address_id:, file:)
        @address_id = address_id
        @file = file
      end

      def validation_errors
        csv_errors = []
        # unique_keys = []
        File.open(@file, "r") do |file|
          row_num = 0
          CSV.foreach(file) do |row|
            row_num = row_num + 1
            next if row_num == 1
            csv = Files::DollarYenTransactionDepositCsv.new(address_id: @address_id, row_num: row_num, row: row)
            # csv.make_unique_key
            errors = csv.valid_errors
            if errors.present?
              csv_errors << errors
            end

            # 一意なkeyを取得
            # unique_key = csv.make_unique_key
            # unique_keys << unique_key
          end
        end
        return csv_errors.flat_map { |a| { msg: a } } if csv_errors.present?
        # 　ここで配列と行列の数が同じかを判断する
        []
      end

      def uniqe_key
      end

      def bulk_insert
      end
    end
  end
# end
