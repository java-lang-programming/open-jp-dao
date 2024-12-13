class CreateDollarYens < ActiveRecord::Migration[8.0]
  def change
    create_table :dollar_yens do |t|
      t.date :date
      t.decimal :dollar_yen_nakane, null: false

      t.timestamps
    end
    add_index :dollar_yens, :date, unique: true
  end
end
