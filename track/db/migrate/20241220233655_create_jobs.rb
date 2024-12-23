class CreateJobs < ActiveRecord::Migration[8.0]
  def change
    create_table :jobs do |t|
      t.string :name, null: false, comment: "名称"
      t.text :summary, null: false, comment: "概要"

      t.timestamps
    end
  end
end
