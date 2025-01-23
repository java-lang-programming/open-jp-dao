class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.string :message, null: false, comment: "メッセージ"
      t.timestamp :start_at, null: false, comment: "通知開始日"
      t.timestamp :end_at, null: false, comment: "通知終了日"
      t.integer :priority, null: false, default: 1, comment: "優先度が高いほど優先される。デフォルトは1"

      t.timestamps
    end
  end
end
