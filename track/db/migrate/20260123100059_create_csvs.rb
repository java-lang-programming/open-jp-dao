class CreateCsvs < ActiveRecord::Migration[8.1]
  def change
    create_table :csvs do |t|
      t.string :name, null: false, comment: "名称"

      t.timestamps
    end
  end
end
