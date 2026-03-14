class CreateSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :settings do |t|
      t.references :address, null: false, foreign_key: true, comment: "address_idに紐づく"
      t.integer :default_year, null: false, comment: "デフォルト年度"
      t.string :language, null: false, default: 'ja', comment: "言語"

      t.timestamps
    end
  end
end
