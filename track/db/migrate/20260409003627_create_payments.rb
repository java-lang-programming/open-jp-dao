class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.string :name, null: false, comment: "支払い名称"
      t.integer :status, null: false, default: 0, comment: "ステータス"

      t.timestamps
    end
  end
end
