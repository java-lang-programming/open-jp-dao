# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# 　コメントではなく、ロジックで入れたい

# 　開発用のデータと本番をmaskしたデータは分ける。でないと肥大化してしまうので。
# 　負荷テストと開発は別である。

# テスト用データの作成
puts "address作成"
address1 = Address.create!(
   address: '0x91582E868c62FA205d38BeBaB7B903322A4CC89D',
   kind: Address.kinds[:ethereum]
)

# address2 = Address.create!(
#    address: '0x00002E868c62FA205d38BeBaB7B903322A4CC89D',
#    kind: Address.kinds[:ethereum]
# )

# address3 = Address.create!(
#    address: '0xcd7805878b581380ad0498cf4a01fbfc32eaf9cc',
#    kind: Address.kinds[:solana]
# )

# puts Address.all.inspect

puts "address作成終了"

puts "address1のTransactionType作成"
# 本来は画面から作成する　これはまだ未作成

TransactionType.create!(
   name: "HDV配当入金",
   kind: TransactionType.kinds[:deposit],
   address: address1
)

TransactionType.create!(
   name: "VYM配当入金",
   kind: TransactionType.kinds[:deposit],
   address: address1
)

TransactionType.create!(
   name: "TLT配当入金",
   kind: TransactionType.kinds[:deposit],
   address: address1
)

TransactionType.create!(
   name: "住信SBI利子",
   kind: TransactionType.kinds[:deposit],
   address: address1
)

TransactionType.create!(
   name: "ドルを円に変換",
   kind: TransactionType.kinds[:withdrawal],
   address: address1
)

puts "TransactionType作成終了"

puts "Job作成開始"

FactoryBot.build(:job_1)
FactoryBot.build(:job_2)

puts "Job作成終了"

puts "ドル円2024マスタ投入"
csv_dollar_yen_2024_path = Rails.root.join("db", "seeds", "dollar_yens_2024.csv")
service = FileUploads::DollarYenCsv.new(file: csv_dollar_yen_2024_path)
service.execute

puts "ドル円2025マスタ投入"
csv_dollar_yen_2025_path = Rails.root.join("db", "seeds", "dollar_yens_2025.csv")
service = FileUploads::DollarYenCsv.new(file: csv_dollar_yen_2025_path)
service.execute

puts "ドル円マスタ投入完了"

puts "お知らせ(header)作成"

Notification.create!(
   message: "確定申告は2026年2月から開始されます。早めに準備をしておきましょう。",
   start_at: Time.now,
   end_at: Time.now.tomorrow,
   priority: 1
)

# 　csv importようにテストデータ
# puts "トランザクションデータ"
# import_file = ImportFile.new(address: address, job: job, status: ImportFile.statuses[:ready])
# test_deposit_csv_dev_path = Rails.root.join("test_deposit_csv_dev.csv")
# puts test_deposit_csv_dev_path
# file = File.new(test_deposit_csv_dev.csv)
# import_file.file.attach(file)
# import_file.save

# DollarYenTransactionsCsvImportJob.perform_later(import_file_id: import_file.id)
# puts "トランザクションデータ作成完了"
