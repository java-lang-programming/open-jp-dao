class CreateDollarYenTransactions < ActiveRecord::Migration[7.2]
  def change
    create_table :dollar_yen_transactions do |t|
      t.references :transaction_type
      t.date :date, null: false, comment: "取引日"
      t.decimal :deposit_rate, comment: "預入レート"
      t.decimal :deposit_quantity, comment: "預入数量米ドル"
      t.decimal :deposit_en, comment: "預入円換算"
      t.decimal :withdrawal_rate, comment: "払出レート"
      t.decimal :withdrawal_quantity, comment: "払出数量米ドル"
      t.decimal :withdrawal_en, comment: "払出円換算"
      t.decimal :exchange_en, comment: "交換した円価格"
      t.decimal :exchange_difference, comment: "交換した円と払出円換算の差額"
      t.decimal :balance_rate, null: false, comment: "残帳簿価格レート"
      t.decimal :balance_quantity, null: false, comment: "残帳簿価格数量米ドル"
      t.decimal :balance_en, null: false, comment: "残帳簿価格円換算"
      t.references :address
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :dollar_yen_transactions, [ :transaction_type_id, :date ], unique: true
  end
end
