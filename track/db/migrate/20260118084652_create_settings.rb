class CreateSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :settings do |t|
      t.references :address, null: false, foreign_key: true, comment: "address_idに紐づく"
      t.integer :default_year, null: false
      t.string :language, null: false, default: 'ja'

      t.timestamps
    end
  end
end
