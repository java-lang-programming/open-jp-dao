class CreateAddresses < ActiveRecord::Migration[7.2]
  def change
    create_table :addresses do |t|
      t.string :address, null: false, comment: "アドレス"
      t.integer :kind, null: false, comment: "チェーン種別"
      t.string :ens_name, comment: "Ethereum Name Service"
      t.string :sns, comment: "Solana Name Service"
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
