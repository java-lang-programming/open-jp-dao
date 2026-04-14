class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name, null: false, comment: "商品名"
      t.text :description, null: false, comment: "商品の説明"
      t.integer :price, null: false, default: 0, comment: "価格"
      t.integer :status, null: false, default: 0, comment: "ステータス"
      t.datetime :published_at
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :products, :status
    add_index :products, :published_at
    add_index :products, :deleted_at
  end
end
