class CreateLedgerItems < ActiveRecord::Migration[8.0]
  def change
    create_table :ledger_items do |t|
      t.string :name, null: false, comment: "仕訳項目名"
      t.integer :kind, null: false, comment: "仕訳項目種類"
      t.string :summary, comment: "概要"
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
