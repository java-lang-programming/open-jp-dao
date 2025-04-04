# 楽天のクレジットカード
# versionとかあるのかな？？

require "csv"
require 'bigdecimal'


CSV_FOLDER = "/Users/masayasuzuki/workplace/study/kakushin/csvs"

CSV_ROW_NAME_INDEX = 1
CSV_ROW_COST_INDEX = 4


# 費用データ
# target
# distribution 0 なし, 1あり
# kind: 1 (通信費), 2 (水道光熱費)
# extra_service_fee 不要なサービス
NET_COST = { name: "ＮＴＴ東日本光コラボ回収", distribution: { flg: 1, ratio: 0.8, extra_service_fee: 825 }, kind: 1 }
KEITAI_COST = { name: "ｿﾌﾄﾊﾞﾝｸM", distribution: { flg: 1, ratio: 0.8 }, kind: 1 }
DENKI = { name: "ＥＮＥＯＳ　Ｐｏｗｅｒ（電気）", distribution: { flg: 1, ratio: 0.2 }, kind: 2 }


# 結果
# 　お支払日 , 電気, 電気経費
result = []

# 本来はcsvファイルの一覧から取得する
csv_2025_01 = CSV_FOLDER + "/" + "enavi202501(4071).csv"


# 　ここから全てのリスト

index_header = 0
CSV.foreach(csv_2025_01, liberal_parsing: true) do |row|
  index_header = index_header + 1
  # 　ここでheaderをチェックする
  next if index_header == 1
  # p row


  # 経費
  exponse_all = {}

  # 　引き落としの日を取得可能にしておく
  shiharaibi = "2025/01/27"
  name = row[CSV_ROW_NAME_INDEX]

  # 　以下のコードは関数化する
  # ネット通信費
  net_result = {}
  if name.include?(NET_COST[:name])
    cost = row[CSV_ROW_COST_INDEX]
    puts NET_COST[:name]
    puts cost
    if NET_COST[:distribution][:flg] == 1
      ratio = NET_COST[:distribution][:ratio]
      # 　これはある場合とない場合があるよ
      extra_service_fee = NET_COST[:distribution][:extra_service_fee]
      target_fee = BigDecimal(cost) - BigDecimal(extra_service_fee)
      hiyo = target_fee * BigDecimal(ratio.to_s)
      net_result[:date] = shiharaibi
      # 料金
      net_result[:fee] = target_fee.ceil(4).to_f
      # 経費
      net_result[:expenses] = hiyo.ceil(4).to_f
      # 会社
      net_result[:service_name] = name
    end

    puts "ネット料金"
    puts net_result
  end

  # 携帯
  keitai_result = {}
  if name.include?(KEITAI_COST[:name])
    cost = row[CSV_ROW_COST_INDEX]
    # puts KEITAI_COST[:name]
    # 　按分あり
    if KEITAI_COST[:distribution][:flg] == 1
      ratio = KEITAI_COST[:distribution][:ratio]
      hiyo = BigDecimal(cost) * BigDecimal(ratio.to_s)
      keitai_result[:date] = shiharaibi
      # 料金
      keitai_result[:fee] = BigDecimal(cost).ceil(4).to_f
      # 経費
      keitai_result[:expenses] = hiyo.ceil(4).to_f
      # 会社
      keitai_result[:service_name] = name
    end

    puts "携帯料金"
    puts keitai_result
  end


  # 電気代
  denki_result = {}
  if name.include?(DENKI[:name])
    cost = row[CSV_ROW_COST_INDEX]
    # puts DENKI[:name]
    # puts cost
    # 　按分あり
    if DENKI[:distribution][:flg] == 1
      ratio = DENKI[:distribution][:ratio]
      # puts ratio
      hiyo = BigDecimal(cost) * BigDecimal(ratio.to_s)
      # 支払日
      denki_result[:date] = shiharaibi
      # 料金
      denki_result[:fee] = BigDecimal(cost).ceil(4).to_f
      # 経費
      denki_result[:expenses] = hiyo.ceil(4).to_f
      # 会社
      denki_result[:service_name] = name
    end

    puts "電気代"
    puts denki_result
  end





  # 　国民健康保険

  # str.match(/.+が食べたい/)
end
