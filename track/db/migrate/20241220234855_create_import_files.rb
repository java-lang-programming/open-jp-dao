class CreateImportFiles < ActiveRecord::Migration[8.0]
  def change
    create_table :import_files do |t|
      t.references :job, null: false, foreign_key: true, comment: "実行job"
      t.references :address, null: false, foreign_key: true, comment: "実行者アドレス"
      t.integer :status, null: false, comment: "実行ステータス"

      t.timestamps
    end
  end
end
