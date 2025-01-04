class CreateAddresses < ActiveRecord::Migration[7.2]
  def change
    create_table :addresses do |t|
      t.string :address, null: false, comment: "アドレス"
      t.integer :kind, null: false, comment: "チェーン種別"
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
