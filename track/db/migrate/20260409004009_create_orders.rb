class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.string :uuid, null: false, comment: "注文識別用UUID"
      t.references :product, null: false, foreign_key: true, comment: "購入商品"
      t.integer :price, null: false, default: 0, comment: "購入時の価格"
      t.references :address, null: false, foreign_key: true, comment: "address"
      t.references :payment, null: false, foreign_key: true, comment: "支払い方法"
      t.integer :status, null: false, default: 0, comment: "注文ステータス"
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :orders, :uuid, unique: true
    add_index :orders, :deleted_at
  end
end
