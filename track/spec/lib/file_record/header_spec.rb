require 'rails_helper'

RSpec.describe FileRecord::Header, type: :lib do
  # ダミークラス
  let(:dummy_class) do
    Class.new do
      include FileRecord::Header
    end
  end

  let(:instance) { dummy_class.new }
  let(:kind) { FileUploads::GenerateMaster::LEDGER_YAML }
  let(:master) { FileUploads::GenerateMaster.new(kind: kind).master }
  let(:ledger_csv_header_path) { fixture_file_upload("#{Rails.root}/spec/files/uploads/ledger_csv/header.csv") }
  let(:dollar_yen_transaction_csv_header_path) { fixture_file_upload("#{Rails.root}/spec/files/uploads/dollar_yen_transaction_csv/header.csv") }

  describe "#validate_header_fields" do
    context 'dollar_yen_transaction' do
      let(:kind) { FileUploads::GenerateMaster::DOLLAR_YEN_TRANSACTION_YAML }

      # csvに指定されているfieldsが正常
      it 'should be []'  do
        result = instance.validate_header_fields(
          file_path: dollar_yen_transaction_csv_header_path,
          master: master
        )
        expect(result).to eq([])
      end

      # dollar_yen_transaction以外のcsvをuploadした場合
      it 'should be errors'  do
        result = instance.validate_header_fields(
          file_path: ledger_csv_header_path,
          master: master
        )
        expect(result).to eq(
          {
            errors: [
              { row: 1, col: 2, attribute: "transaction_type", value: "ledger_item", message: "ヘッダの属性名が不正です。正しい属性名はtransaction_typeです。" },
              { row: 1, col: 3, attribute: "deposit_quantity", value: "name", message: "ヘッダの属性名が不正です。正しい属性名はdeposit_quantityです。" },
              { row: 1, col: 4, attribute: "deposit_rate", value: "face_value", message: "ヘッダの属性名が不正です。正しい属性名はdeposit_rateです。" },
              { row: 1, col: 5, attribute: "withdrawal_quantity", value: "proportion_rate", message: "ヘッダの属性名が不正です。正しい属性名はwithdrawal_quantityです。" },
              { row: 1, col: 6, attribute: "exchange_en", value: "proportion_amount", message: "ヘッダの属性名が不正です。正しい属性名はexchange_enです。" }
            ]
          }
        )
      end
    end

    context 'ledger' do
      # csvに指定されているfieldsが正常
      it 'should be []'  do
        result = instance.validate_header_fields(
          file_path: ledger_csv_header_path,
          master: master
        )
        expect(result).to eq([])
      end

      # ledger以外のcsvをuploadした場合
      it 'should be errors'  do
        result = instance.validate_header_fields(
          file_path: dollar_yen_transaction_csv_header_path,
          master: master
        )
        expect(result).to eq(
          {
            errors: [
              { row: 1, col: 2, attribute: "ledger_item", value: "transaction_type", message: "ヘッダの属性名が不正です。正しい属性名はledger_itemです。" },
              { row: 1, col: 3, attribute: "name", value: "deposit_quantity", message: "ヘッダの属性名が不正です。正しい属性名はnameです。" },
              { row: 1, col: 4, attribute: "face_value", value: "deposit_rate", message: "ヘッダの属性名が不正です。正しい属性名はface_valueです。" },
              { row: 1, col: 5, attribute: "proportion_rate", value: "withdrawal_quantity", message: "ヘッダの属性名が不正です。正しい属性名はproportion_rateです。" },
              { row: 1, col: 6, attribute: "proportion_amount", value: "exchange_en", message: "ヘッダの属性名が不正です。正しい属性名はproportion_amountです。" }
            ]
          }
        )
      end
    end
  end
end
