class CreateSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :sessions do |t|
      t.references :address, null: false, foreign_key: true
      t.string :ip_address
      t.string :user_agent
      t.integer :chain_id
      t.string :message
      t.string :signature
      t.string :domain

      t.timestamps
    end
  end
end
