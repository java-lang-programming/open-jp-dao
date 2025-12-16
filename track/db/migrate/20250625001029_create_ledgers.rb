class CreateLedgers < ActiveRecord::Migration[8.0]
  def change
    create_table :ledgers do |t|
      t.timestamp :date, null: false, comment: "取引日"
      t.string :name, null: false, comment: "名称"
      t.references :ledger_item, comment: "仕訳帳項目ID"
      t.integer :face_value, null: false, comment: "額面"
      t.decimal :proportion_rate, comment: "按分率"
      t.decimal :proportion_amount, comment: "按分額"
      t.integer :recorded_amount, comment: "計上額"
      t.references :address, comment: "アドレスID"

      t.timestamps
    end
    add_index :ledgers,
              [ :date, :name, :ledger_item_id ],
              unique: true,
              name: 'index_ledgers_unique_date_item_name'
  end
end
