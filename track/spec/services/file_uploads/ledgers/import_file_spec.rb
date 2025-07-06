require 'rails_helper'

RSpec.describe FileUploads::Ledgers::ImportFile, type: :feature do
  let(:addresses_eth) { create(:addresses_eth) }
  let(:ledger_2025_1_6_path) { fixture_file_upload("#{Rails.root}/spec/files/uploads/ledger_csv/2025_1_6.csv") }
  let(:ledger_2025_1_6_errors_path) { fixture_file_upload("#{Rails.root}/spec/files/uploads/ledger_csv/2025_1_6_errors.csv") }
  let(:ledger_csv_sample_path) { fixture_file_upload("#{Rails.root}/spec/files/uploads/ledger_csv/ledger_csv_sample.csv") }
  let(:job_3) { create(:job_3) }
  let(:ledger_item_1) { create(:ledger_item_1) }
  let(:ledger_item_2) { create(:ledger_item_2) }
  let(:ledger_item_3) { create(:ledger_item_3) }

  describe 'validate_errors_of_complex_data' do
    before do
      job_3
      ledger_item_2
      ledger_item_3
    end

    context 'エラーなし' do
      it "should be empty array." do
        ledger_item_1
        csv = FileUploads::Ledgers::File.new(address: addresses_eth, file: ledger_2025_1_6_path)
        import_file = csv.create_import_file
        csv = FileUploads::Ledgers::ImportFile.new(import_file: import_file)
        errors = csv.validate_errors_of_complex_data
        expect(errors).to eq([])
      end
    end

    context 'エラーあり' do
      # ledger_item_1をDBに入れない
      it "should be errors array." do
        csv = FileUploads::Ledgers::File.new(address: addresses_eth, file: ledger_csv_sample_path)
        import_file = csv.create_import_file
        csv = FileUploads::Ledgers::ImportFile.new(import_file: import_file)
        errors = csv.validate_errors_of_complex_data
        expect(errors.size).to eq(5)
        expect(errors[0]).to eq({ row: 2, col: 2, attribute: "ledger_item", value: "通信費", message: "通信費はledger_itemに存在しません" })
        expect(errors[1]).to eq({ row: 3, col: 2, attribute: "ledger_item", value: "通信費", message: "通信費はledger_itemに存在しません" })
        expect(errors[2]).to eq({ row: 4, col: 2, attribute: "ledger_item", value: "通信費", message: "通信費はledger_itemに存在しません" })
        expect(errors[3]).to eq({ row: 5, col: 2, attribute: "ledger_item", value: "通信費", message: "通信費はledger_itemに存在しません" })
        expect(errors[4]).to eq({ row: 6, col: 2, attribute: "ledger_item", value: "通信費", message: "通信費はledger_itemに存在しません" })
      end
    end
  end

  describe 'save_error' do
    before do
      job_3
      ledger_item_2
      ledger_item_3
    end

    context 'エラーを保存' do
      it "should be save error_json." do
        csv = FileUploads::Ledgers::File.new(address: addresses_eth, file: ledger_csv_sample_path)
        import_file = csv.create_import_file
        csv = FileUploads::Ledgers::ImportFile.new(import_file: import_file)
        errors = csv.validate_errors_of_complex_data
        csv.save_error(error_json: errors)

        import_file_errors = addresses_eth.import_files.first.import_file_errors
        expect(import_file_errors.size).to eq(1)
        expect(import_file_errors.first.error_json).to eq(errors.to_json)
      end
    end
  end

  describe 'generate_ledgers' do
    before do
      job_3
      ledger_item_1
      ledger_item_2
      ledger_item_3
    end

    after do
      # テスト用フォルダごとファイル削除
      FileUtils.rm_rf(ActiveStorage::Blob.service.root)
    end

    context 'データありで事項' do
      it "should be status ready." do
        csv = FileUploads::Ledgers::File.new(address: addresses_eth, file: ledger_2025_1_6_path)
        import_file = csv.create_import_file
        csv = FileUploads::Ledgers::ImportFile.new(import_file: import_file)
        ledgers = csv.generate_ledgers

        expect(ledgers.size).to eq(25)
      end
    end
  end
end
