# 楽天カード
module Csvs
  class RakutenCard
    attr_accessor :file_path

    NAME_INDEX = 1
    COST_INDEX = 4

    def initialize(file_path:)
      @file = file
      @csvs = []
    end

    # def list(targets:, withdrawal_date:)
    #   NET_COST = {name: "ＮＴＴ東日本光コラボ回収", distribution: {flg: 1, ratio: 0.8, extra_service_fee: 825}, kind: 1}
    #   KEITAI_COST = {name: "ｿﾌﾄﾊﾞﾝｸM", distribution: {flg: 1, ratio: 0.8}, kind: 1}
    #   DENKI = {name: "ＥＮＥＯＳ　Ｐｏｗｅｒ（電気）", distribution: {flg: 1, ratio: 0.2}, kind: 2}

    #   # データベースから取得
    #   temp_targets = [
    #     NET_COST,
    #     KEITAI_COST,
    #     DENKI
    #   ]

    #   File.open(@file, "r") do |file|
    #     row_num = 0
    #     CSV.foreach(file) do |row|
    #       #　headerのチェック
    #       row_num = row_num + 1
    #       next if row_num == 1


    #       name = row[Csvs::RakutenCard::NAME_INDEX]
    #       cost = row[Csvs::RakutenCard::COST_INDEX]

    #       temp_targets.each do |target|
    #         if name.include?(target[:name])
    #           if target[:distribution][:flg] == 1
    #             ratio = target[:distribution][:ratio]
    #             extra_service_fee = target[:distribution][:extra_service_fee]
    #             fee = BigDecimal(cost)
    #             if extra_service_fee.present?
    #               fee = fee - BigDecimal(extra_service_fee)
    #             end
    #             expenses = fee * BigDecimal(ratio.to_s)
    #             #　ここでモデルに入れる

    #             net_result[:date] = shiharaibi
    #             # 料金
    #             net_result[:fee] = target_fee.ceil(4).to_f
    #             # 経費
    #             net_result[:expenses] = hiyo.ceil(4).to_f
    #             # 会社
    #             net_result[:service_name] = name

    #           end
    #         end
    #         break
    #       end
    #     end
    #   end
    # end
  end
end
