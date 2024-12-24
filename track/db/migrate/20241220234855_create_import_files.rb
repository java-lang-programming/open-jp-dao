class CreateImportFiles < ActiveRecord::Migration[8.0]
  def change
    create_table :import_files do |t|
      t.references :job, null: false, foreign_key: true
      t.references :address, null: false, foreign_key: true

      t.timestamps
    end
  end
end
