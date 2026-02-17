require 'rails_helper'

RSpec.describe FileUploads::Ledgers::RakutenCardFile, type: :feature do
  let(:addresses_eth) { create(:addresses_eth) }
  let(:rakuten_card_sample_path) { fixture_file_upload("#{Rails.root}/spec/files/uploads/rakuten_card/enavi202412.csv") }
  let(:ledger_csv_sample_path) { fixture_file_upload("#{Rails.root}/spec/files/uploads/ledger_csv/ledger_csv_sample.csv") }
  let(:target_file) {
    rakuten_card_sample_path
  }
  let(:instance) {
    described_class.new(address: addresses_eth, file: target_file)
  }

  describe '#validate_headers' do
    it 'get empty array.' do
      errors = instance.validate_headers
      expect(errors).to eq([])
    end

    context 'when csv is ledger_csv' do
      let(:target_file) {
        ledger_csv_sample_path
      }

      # ヘッダー数が異なる
      it 'get errors.' do
        errors = instance.validate_headers
        expect(errors[:errors].size).to eq(1)
        expect(errors[:errors][0]).to eq(
                                        {
                                           row: 1,
                                           col: nil,
                                           attribute: "",
                                           value: "",
                                           message: "ヘッダの属性名の数が不足しています。ファイルのヘッダー情報を再確認してください。"
                                         })
      end
    end
  end
end
