class CreateExternalServiceTransactionTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :external_service_transaction_types do |t|
      t.references :external_service
      t.string :name, null: false, comment: "外部サービス取引名称"
      t.references :transaction_type
      t.timestamp :deleted_at

      t.timestamps
    end

    add_index :external_service_transaction_types,
              [ :external_service_id, :name ],
              unique: true,
              name: 'idx_external_service_tx_types_on_service_id_and_name'
  end
end
