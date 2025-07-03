require 'rails_helper'

RSpec.describe FileUploads::LedgerCsv, type: :feature do
  let(:addresses_eth) { create(:addresses_eth) }
  let(:ledger_2025_1_6_path) { "#{Rails.root}/spec/files/uploads/ledger_csv/2025_1_6.csv" }
  let(:ledger_2025_1_6_errors_path) { "#{Rails.root}/spec/files/uploads/ledger_csv/2025_1_6_errors.csv" }
  let(:job_3) { create(:job_3) }
  let(:ledger_item_1) { create(:ledger_item_1) }
  let(:ledger_item_2) { create(:ledger_item_2) }
  let(:ledger_item_3) { create(:ledger_item_3) }


  describe 'validate_header_fileds' do
    let(:ledger_csv_header_sample_path) { "#{Rails.root}/spec/files/uploads/ledger_csv/ledger_csv_header_sample.csv" }
    # ヘッダーの属性数が多い
    let(:ledger_csv_many_header_sample_path) { "#{Rails.root}/spec/files/uploads/ledger_csv/ledger_csv_many_header_sample.csv" }
    # ヘッダーの属性数が不足
    let(:ledger_csv_shortage_header_sample_path) { "#{Rails.root}/spec/files/uploads/ledger_csv/ledger_csv_shortage_header_sample.csv" }
    # ヘッダーの属性が不正な属性名がある
    let(:ledger_csv_invalid_name_header_sample_path) { "#{Rails.root}/spec/files/uploads/ledger_csv/ledger_csv_invalid_name_header_sample.csv" }

    context 'ヘッダーが不正' do
      # ヘッダーの属性が多い
      it "should be errors when failure" do
        csv = FileUploads::LedgerCsv.new(address: addresses_eth, file_path: ledger_csv_many_header_sample_path)
        expect(csv.validate_headers[0]).to eq({
          row: 1,
          col: nil,
          attribute: "",
          value: "",
          message: "ヘッダの属性名の数が多いです。ファイルのヘッダー情報を再確認してください。"
        })
      end

      # 　ヘッダーの属性が少ない
      it "should be errors when failure" do
        csv = FileUploads::LedgerCsv.new(address: addresses_eth, file_path: ledger_csv_shortage_header_sample_path)
        expect(csv.validate_headers[0]).to eq({
          row: 1,
          col: nil,
          attribute: "",
          value: "",
          message: "ヘッダの属性名の数が不足しています。ファイルのヘッダー情報を再確認してください。"
        })
      end

      # ヘッダーの属性が不正な属性名がある
      it "should be errors when failure" do
        csv = FileUploads::LedgerCsv.new(address: addresses_eth, file_path: ledger_csv_invalid_name_header_sample_path)
        result = csv.validate_headers
        expect(result.size).to eq(3)
        expect(result[0]).to eq({
          row: 1,
          col: 3,
          attribute: "name",
          value: "nale",
          message: "ヘッダの属性名が不正です。正しい属性名はnameです。"
        })
        expect(result[1]).to eq({
          row: 1,
          col: 5,
          attribute: "proportion_rate",
          value: "proportion_late",
          message: "ヘッダの属性名が不正です。正しい属性名はproportion_rateです。"
        })
        expect(result[2]).to eq({
          row: 1,
          col: 6,
          attribute: "proportion_amount",
          value: "proportion_bmount",
          message: "ヘッダの属性名が不正です。正しい属性名はproportion_amountです。"
        })
      end
    end

    context 'ヘッダーが正常' do
      it "should be empty array when success" do
        csv = FileUploads::LedgerCsv.new(address: addresses_eth, file_path: ledger_csv_header_sample_path)
        expect(csv.validate_headers).to eq([])
      end
    end
  end

  describe 'validate_errors_of_simple_data' do
    let(:ledger_csv_sample_path) { "#{Rails.root}/spec/files/uploads/ledger_csv/ledger_csv_sample.csv" }
    # 日付がエラー
    let(:ledger_csv_sample_date_errors_path) { "#{Rails.root}/spec/files/uploads/ledger_csv/ledger_csv_sample_date_errors.csv" }

    context 'エラーなし' do
      it "should be empty array." do
        csv = FileUploads::LedgerCsv.new(address: addresses_eth, file_path: ledger_csv_sample_path)
        errors = csv.validate_errors_of_simple_data
        expect(errors).to eq([])
      end
    end

    context 'エラーあり' do
      it "should be date errors array." do
        csv = FileUploads::LedgerCsv.new(address: addresses_eth, file_path: ledger_csv_sample_date_errors_path)
        errors = csv.validate_errors_of_simple_data
        expect(errors.size).to eq(3)
        expect(errors[0]).to eq({
          attribute: "date",
          col: 1,
          row: 2,
          message: "dateのフォーマットが不正です。yyyy/mm/dd形式で入力してください。",
          value: "2025-01-06"
        })
        expect(errors[1]).to eq({
          attribute: "date",
          col: 1,
          row: 4,
          message: "dateの値が不正です。yyyy/mm/dd形式で正しい日付を入力してください。",
          value: "2025/04/32"
        })
        expect(errors[2]).to eq({
          attribute: "date",
          col: 1,
          row: 6,
          message: "dateが未記入です。dateは必須入力です。",
          value: nil
        })
      end
    end
  end

  describe 'valid_string' do
    let(:ledger_csv_sample_path) { "#{Rails.root}/spec/files/uploads/ledger_csv/ledger_csv_sample.csv" }
    # 日付がエラー
    let(:ledger_csv_sample_string_errors_path) { "#{Rails.root}/spec/files/uploads/ledger_csv/ledger_csv_sample_string_errors.csv" }

    context 'エラーなし' do
      it "should be empty array." do
        csv = FileUploads::LedgerCsv.new(address: addresses_eth, file_path: ledger_csv_sample_path)
        errors = csv.validate_errors_of_simple_data
        expect(errors).to eq([])
      end
    end

    context 'エラーあり' do
      it "should be empty array." do
        csv = FileUploads::LedgerCsv.new(address: addresses_eth, file_path: ledger_csv_sample_string_errors_path)
        errors = csv.validate_errors_of_simple_data
        expect(errors.size).to eq(3)
        expect(errors[0]).to eq({
          attribute: "ledger_item",
          col: 2,
          row: 2,
          message: "ledger_itemが未記入です。ledger_itemは必須入力です。",
          value: nil
        })
        expect(errors[1]).to eq({
          attribute: "ledger_item",
          col: 2,
          row: 5,
          message: "ledger_itemの文字が100文字を超えています。100文字以下にしてください。",
          value: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        })
        expect(errors[2]).to eq({
          attribute: "name",
          col: 3,
          row: 6,
          message: "nameの文字が100文字を超えています。100文字以下にしてください。",
          value: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        })
      end
    end
  end

  describe 'validate_errors_of_complex_data' do
    let(:ledger_csv_sample_path) { "#{Rails.root}/spec/files/uploads/ledger_csv/ledger_csv_sample.csv" }

    context 'エラーなし' do
      it "should be empty array." do
        ledger_item_1
        ledger_item_2
        ledger_item_3
        csv = FileUploads::LedgerCsv.new(address: addresses_eth, file_path: ledger_2025_1_6_path)
        errors = csv.validate_errors_of_complex_data
        expect(errors).to eq([])
      end
    end

    context 'エラーあり' do
      # ledger_item_2をDBに入れない
      it "should be errors array." do
        csv = FileUploads::LedgerCsv.new(address: addresses_eth, file_path: ledger_csv_sample_path)
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

  describe 'validate_errors_first' do
    context 'エラーなし' do
      it "should be empty array." do
        csv = FileUploads::LedgerCsv.new(address: addresses_eth, file_path: ledger_2025_1_6_path)
        errors = csv.validate_errors_first
        expect(errors).to eq([])
      end
    end

    context 'エラーあり' do
      it "should be errors array." do
        csv = FileUploads::LedgerCsv.new(address: addresses_eth, file_path: ledger_2025_1_6_errors_path)
        errors = csv.validate_errors_first
        expect(errors.size).to eq(2)
        expect(errors[0]).to eq({ row: 1, col: 5, attribute: "proportion_rate", value: "proportion_rete", message: "ヘッダの属性名が不正です。正しい属性名はproportion_rateです。" })
        expect(errors[1]).to eq({ row: 2, col: 1, attribute: "date", value: "2025/01/32", message: "dateの値が不正です。yyyy/mm/dd形式で正しい日付を入力してください。" })
      end
    end
  end

  describe 'create_import_file' do
    after do
      # テスト用フォルダごとファイル削除
      FileUtils.rm_rf(ActiveStorage::Blob.service.root)
    end

    context 'エラーなし' do
      it "should be status ready." do
        job_3
        csv = FileUploads::LedgerCsv.new(address: addresses_eth, file_path: fixture_file_upload(ledger_2025_1_6_path))
        import_file = csv.create_import_file

        expect(import_file.job_id).to eq(job_3.id)
        expect(import_file.status).to eq("ready")
      end
    end
  end

  describe 'update_status' do
    after do
      # テスト用フォルダごとファイル削除
      FileUtils.rm_rf(ActiveStorage::Blob.service.root)
    end

    context 'データありで事項' do
      it "should be status ready." do
        job_3
        csv = FileUploads::LedgerCsv.new(address: addresses_eth, file_path: fixture_file_upload(ledger_2025_1_6_path))
        import_file = csv.create_import_file

        csv.update_status(status: :in_progress)

        expect(import_file.job_id).to eq(job_3.id)
        expect(import_file.status).to eq("in_progress")
      end
    end
  end

  describe 'generate_ledgers' do
    after do
      # テスト用フォルダごとファイル削除
      FileUtils.rm_rf(ActiveStorage::Blob.service.root)
    end

    context 'データありで事項' do
      it "should be status ready." do
        ledger_item_1
        ledger_item_2
        ledger_item_3
        job_3
        csv = FileUploads::LedgerCsv.new(address: addresses_eth, file_path: fixture_file_upload(ledger_2025_1_6_path))
        ledgers = csv.generate_ledgers

        expect(ledgers.size).to eq(25)
      end
    end
  end

  describe 'save_error' do
    context 'エラーを保存' do
      it "should be save error_json." do
        job_3
        csv = FileUploads::LedgerCsv.new(address: addresses_eth, file_path: fixture_file_upload(ledger_2025_1_6_errors_path))
        errors = csv.validate_errors_first
        csv.save_error(error_json: errors)

        import_file_errors = addresses_eth.import_files.first.import_file_errors
        expect(import_file_errors.size).to eq(1)
        expect(import_file_errors.first.error_json).to eq(errors.to_json)
      end
    end
  end
end
