require 'rails_helper'

# RSpec.describe FileUploads::Ledgers::CsvBaseImportFile, type: :feature do
#   let(:addresses_eth) { create(:addresses_eth) }
#   let(:job_5) { create(:job_5) }
#   # コクミンネンキン
#   let(:ledger_item_5) {
#     create(:ledger_item_5)
#   }
#   # コクミンケンコウホケン
#   let(:ledger_item_6) {
#     create(:ledger_item_6)
#   }
#    # カクテイキヨシユツカケキ
#    let(:ledger_item_7) {
#      create(:ledger_item_7)
#    }
#   # シヨウキボキヨウサイ
#   let(:ledger_item_8) {
#     create(:ledger_item_8)
#   }
#   # ２キ　シヨトク
#   let(:ledger_item_11) {
#     create(:ledger_item_11)
#   }
#   # カ）アイ−ガイシャ
#   let(:ledger_item_13) {
#     create(:ledger_item_13)
#   }
#   let(:csv_1) {
#     create(:csv_1)
#   }
#   let(:csv_ledger_item_1) {
#     create(:csv_ledger_item_1, ledger_item: ledger_item_11, csv: csv_1)
#   }
#   let(:csv_ledger_item_2) {
#     create(:csv_ledger_item_2, ledger_item: ledger_item_5, csv: csv_1)
#   }
#   let(:rakuten_card_sample_path) { fixture_file_upload("#{Rails.root}/spec/files/uploads/rakuten_card/enavi202412.csv") }
#   let(:import_file) {
#     csv = FileUploads::Ledgers::File.new(address: addresses_eth, file: rakuten_card_sample_path)
#     csv.create_import_file
#   }
#   let(:instance) {
#     described_class.new(import_file: import_file)
#   }
#
#   before do
#     job_4
#     ledger_item_5
#     ledger_item_6
#     ledger_item_7
#     ledger_item_8
#     ledger_item_11
#     ledger_item_13
#     csv_ledger_item_1
#     csv_ledger_item_2
#   end
#
#   after do
#     # テスト用フォルダごとファイル削除
#     FileUtils.rm_rf(ActiveStorage::Blob.service.root)
#   end
#
#   describe '#make_csv_rows_via_import' do
#     before do
#       instance
#     end
#
#     it 'get 2 items.' do
#       csv_rows = instance.csv_rows
#       expect(csv_rows.size).to eq(2)
#       expect(csv_rows[0].row[2]).to eq('６ネン２キ　シヨトク')
#       expect(csv_rows[1].row[2]).to eq('コクミンネンキン')
#     end
#   end
#
#   # describe 'save_error' do
#   #   before do
#   #     job_3
#   #     ledger_item_2
#   #     ledger_item_3
#   #   end
#   #
#   #   context 'エラーを保存' do
#   #     it "should be save error_json." do
#   #       csv = FileUploads::Ledgers::File.new(address: addresses_eth, file: ledger_csv_sample_path)
#   #       import_file = csv.create_import_file
#   #       csv = FileUploads::Ledgers::ImportFile.new(import_file: import_file)
#   #       errors = csv.validate_errors_of_complex_data
#   #       csv.save_error(error_json: errors)
#   #
#   #       import_file_errors = addresses_eth.import_files.first.import_file_errors
#   #       expect(import_file_errors.size).to eq(1)
#   #       expect(import_file_errors.first.error_json).to eq(errors.to_json)
#   #     end
#   #   end
#   # end
#
#   describe '#generate_ledgers' do
#     context 'when upsert_all' do
#       it "should be upsert_all data." do
#         ledgers = instance.generate_ledgers
#         expect(ledgers.size).to eq(2)
#         expect(ledgers[0][:ledger_item_id]).to eq(ledger_item_11.id)
#         expect(ledgers[0][:name]).to eq('６ネン２キ　シヨトク')
#         expect(ledgers[1][:ledger_item_id]).to eq(ledger_item_5.id)
#         expect(ledgers[1][:name]).to eq('コクミンネンキン')
#       end
#     end
#   end
# end
