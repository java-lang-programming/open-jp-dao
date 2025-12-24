class CreateExternalServices < ActiveRecord::Migration[8.1]
  def change
    create_table :external_services do |t|
      t.string :name, null: false, comment: "外部サービス名"
      t.timestamp :deleted_at

      t.timestamps
    end
  end
end
