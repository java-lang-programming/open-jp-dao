class CreateImportFileErrors < ActiveRecord::Migration[8.0]
  def change
    create_table :import_file_errors do |t|
      t.references :import_file, comment: "import_fileID"
      t.json :error_json, comment: "エラーjson"

      t.timestamps
    end
  end
end
