class CreateTransactionTypes < ActiveRecord::Migration[7.2]
  def change
    create_table :transaction_types do |t|
      t.string :name
      t.integer :kind
      t.references :address
      t.timestamp :deleted_at

      t.timestamps
    end
  end
end
