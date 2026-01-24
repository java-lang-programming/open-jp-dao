class CreateCsvLedgerItems < ActiveRecord::Migration[8.1]
  def change
    create_table :csv_ledger_items do |t|
      t.references :ledger_item, comment: "仕訳帳項目ID"
      t.references :csv, comment: "csvID"
      t.string :content, null: false, comment: "内容"
      t.integer :exact_match, null: false, comment: "内容が完全一致かどうか"
      t.decimal :proportion_rate, comment: "按分率"
      t.decimal :proportion_amount, comment: "按分額"

      t.timestamps
    end
  end
end
