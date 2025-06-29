require 'rails_helper'

RSpec.describe FileUploads::LedgerCsv, type: :feature do
  # let(:addresses_eth) { create(:addresses_eth) }
  # let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }

  describe 'validate_header_fileds' do
    let(:addresses_eth) { create(:addresses_eth) }
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
          messaga: "ヘッダの属性名の数が多いです。ファイルのヘッダー情報を再確認してください。"
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
          messaga: "ヘッダの属性名の数が不足しています。ファイルのヘッダー情報を再確認してください。"
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
          messaga: "ヘッダの属性名が不正です。正しい属性名はnameです。"
        })
        expect(result[1]).to eq({
          row: 1,
          col: 5,
          attribute: "proportion_rate",
          value: "proportion_late",
          messaga: "ヘッダの属性名が不正です。正しい属性名はproportion_rateです。"
        })
        expect(result[2]).to eq({
          row: 1,
          col: 6,
          attribute: "proportion_amount",
          value: "proportion_bmount",
          messaga: "ヘッダの属性名が不正です。正しい属性名はproportion_amountです。"
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
    let(:addresses_eth) { create(:addresses_eth) }
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
          messaga: "dateのフォーマットが不正です。yyyy/mm/dd形式で入力してください。",
          value: "2025-01-06"
        })
        expect(errors[1]).to eq({
          attribute: "date",
          col: 1,
          row: 4,
          messaga: "dateの値が不正です。yyyy/mm/dd形式で正しい日付を入力してください。",
          value: "2025/04/32"
        })
        expect(errors[2]).to eq({
          attribute: "date",
          col: 1,
          row: 6,
          messaga: "dateが未記入です。dateは必須入力です。",
          value: nil
        })
      end
    end
  end

  describe 'valid_string' do
    let(:addresses_eth) { create(:addresses_eth) }
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
          messaga: "ledger_itemが未記入です。ledger_itemは必須入力です。",
          value: nil
        })
        expect(errors[1]).to eq({
          attribute: "ledger_item",
          col: 2,
          row: 5,
          messaga: "ledger_itemの文字が100文字を超えています。100文字以下にしてください。",
          value: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        })
        expect(errors[2]).to eq({
          attribute: "name",
          col: 3,
          row: 6,
          messaga: "nameの文字が100文字を超えています。100文字以下にしてください。",
          value: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        })
      end
    end
  end
end
