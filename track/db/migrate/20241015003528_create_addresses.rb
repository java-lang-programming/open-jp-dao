class CreateAddresses < ActiveRecord::Migration[7.2]
  def change
    create_table :addresses do |t|
      t.string :address
      t.integer :kind
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
