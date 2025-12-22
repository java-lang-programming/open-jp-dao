# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Job作成開始"

FactoryBot.create(:job_1)
FactoryBot.create(:job_2)
FactoryBot.create(:job_3)

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

puts "お知らせ(header)s終了"

puts "仕訳項目マスタ作成"

FactoryBot.create(:ledger_item_1)
FactoryBot.create(:ledger_item_2)
FactoryBot.create(:ledger_item_3)
FactoryBot.create(:ledger_item_4)
FactoryBot.create(:ledger_item_5)
FactoryBot.create(:ledger_item_6)
FactoryBot.create(:ledger_item_7)
FactoryBot.create(:ledger_item_8)
FactoryBot.create(:ledger_item_9)
FactoryBot.create(:ledger_item_10)
FactoryBot.create(:ledger_item_11)
FactoryBot.create(:ledger_item_12)
FactoryBot.create(:ledger_item_13)

puts "仕訳項目マスタ作成終了"
