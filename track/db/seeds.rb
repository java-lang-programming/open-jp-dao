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
   address: '0x00001E868c62FA205d38BeBaB7B903322A4CC89D',
   kind: Address.kinds[:ethereum]
)

address2 = Address.create!(
   address: '0x00002E868c62FA205d38BeBaB7B903322A4CC89D',
   kind: Address.kinds[:ethereum]
)

address3 = Address.create!(
   address: '0xcd7805878b581380ad0498cf4a01fbfc32eaf9cc',
   kind: Address.kinds[:solana]
)

# puts Address.all.inspect

puts "address作成終了"

puts "TransactionType作成"
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

# puts TransactionType.all.inspect

puts "TransactionType作成終了"
