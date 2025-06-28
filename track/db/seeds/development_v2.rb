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

puts "v2処理スタート"

puts "仕訳項目マスタ作成"

FactoryBot.build(:ledger_item_1)
FactoryBot.build(:ledger_item_2)
FactoryBot.build(:ledger_item_3)
FactoryBot.build(:ledger_item_4)

puts "仕訳項目マスタ作成終了"

puts "Job作成開始"

FactoryBot.build(:job_3)

puts "Job作成終了"
