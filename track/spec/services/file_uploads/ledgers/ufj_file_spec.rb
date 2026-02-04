require 'rails_helper'

RSpec.describe FileUploads::Ledgers::UfjFile, type: :feature do
  let(:addresses_eth) { create(:addresses_eth) }
  let(:ufj_sample_path) { fixture_file_upload("#{Rails.root}/spec/files/uploads/ufj/decode_4615179_20250127092225.csv") }
  let(:ledger_csv_sample_path) { fixture_file_upload("#{Rails.root}/spec/files/uploads/ledger_csv/ledger_csv_sample.csv") }
  let(:instance) {
    described_class.new(address: addresses_eth, file: ufj_sample_path)
  }

  describe '#validate_headers' do
    it 'get empty array.' do
      errors = instance.validate_headers
      expect(errors).to eq([])
    end

    context 'when csv is ledger_csv' do
      let(:ufj_sample_path) { ledger_csv_sample_path }

      it 'get errors.' do
        errors = instance.validate_headers
        expect(errors[:errors].size).to eq(6)
        expect(errors[:errors][0]).to eq(
                                        {
                                           row: 1,
                                           col: 1,
                                           attribute: "日付",
                                           value: "date",
                                           message: "ヘッダの属性名が不正です。正しい属性名は日付です。"
                                         })
      end
    end
  end
end
