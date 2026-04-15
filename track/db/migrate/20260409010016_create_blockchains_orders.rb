class CreateBlockchainsOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :blockchains_orders do |t|
      t.references :order, null: false, foreign_key: true, comment: "注文"
      t.string :chain_id, null: false, comment: "チェーン"
      t.string :tx_hash, null: false, comment: "トランザクションID"
      t.string :from_address, comment: "誰が払ったか"
      t.string :to_address, comment: "どこに払ったか"
      t.integer :block_number
      t.decimal :amount, precision: 36, scale: 18, comment: "10^18 (ether単位) を考慮した精度"

      t.timestamps
    end
    add_index :blockchains_orders, :tx_hash, unique: true
  end
end
