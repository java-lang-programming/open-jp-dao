require 'rails_helper'

RSpec.describe FileUploads::SumishinSbi::Nyushukinmeisai, type: :feature do
  let(:addresses_eth) { create(:addresses_eth) }
  let(:nyushukinmeisai_csv_sample_path) { fixture_file_upload("#{Rails.root}/spec/files/uploads/sumishin_sbi/nyushukinmeisai_20251223.csv") }
  let(:job_3) { create(:job_3) }
  let(:ledger_item_1) { create(:ledger_item_1) }
  let(:ledger_item_2) { create(:ledger_item_2) }
  let(:ledger_item_3) { create(:ledger_item_3) }
  let(:instance) {
    described_class.new(
      address: addresses_eth,
      file: nyushukinmeisai_csv_sample_path
    )
  }

  describe 'validate_header_fileds' do
    # let(:ledger_csv_header_path) { fixture_file_upload("#{Rails.root}/spec/files/uploads/ledger_csv/header.csv") }
    # # ヘッダーの属性数が多い
    # let(:ledger_csv_many_header_sample_path) { fixture_file_upload("#{Rails.root}/spec/files/uploads/ledger_csv/ledger_csv_many_header_sample.csv") }
    # # ヘッダーの属性数が不足
    # let(:ledger_csv_shortage_header_sample_path) { fixture_file_upload("#{Rails.root}/spec/files/uploads/ledger_csv/ledger_csv_shortage_header_sample.csv") }
    # # ヘッダーの属性が不正な属性名がある
    # let(:ledger_csv_invalid_name_header_sample_path) { fixture_file_upload("#{Rails.root}/spec/files/uploads/ledger_csv/ledger_csv_invalid_name_header_sample.csv") }

    # context 'ヘッダーが不正' do
    #   # ヘッダーの属性が多い
    #   it "should be errors when failure" do
    #     csv = FileUploads::Ledgers::File.new(address: addresses_eth, file: ledger_csv_many_header_sample_path)
    #     result = csv.validate_headers
    #     expect(result[:errors][0]).to eq({
    #       row: 1,
    #       col: nil,
    #       attribute: "",
    #       value: "",
    #       message: "ヘッダの属性名の数が多いです。ファイルのヘッダー情報を再確認してください。"
    #     })
    #   end
    #
    #   # 　ヘッダーの属性が少ない
    #   it "should be errors when failure" do
    #     csv = FileUploads::Ledgers::File.new(address: addresses_eth, file: ledger_csv_shortage_header_sample_path)
    #     result = csv.validate_headers
    #     expect(result[:errors][0]).to eq({
    #       row: 1,
    #       col: nil,
    #       attribute: "",
    #       value: "",
    #       message: "ヘッダの属性名の数が不足しています。ファイルのヘッダー情報を再確認してください。"
    #     })
    #   end
    #
    #   # ヘッダーの属性が不正な属性名がある
    #   it "should be errors when failure" do
    #     csv = FileUploads::Ledgers::File.new(address: addresses_eth, file: ledger_csv_invalid_name_header_sample_path)
    #     result = csv.validate_headers
    #     expect(result[:errors].size).to eq(3)
    #     expect(result[:errors][0]).to eq({
    #       row: 1,
    #       col: 3,
    #       attribute: "name",
    #       value: "nale",
    #       message: "ヘッダの属性名が不正です。正しい属性名はnameです。"
    #     })
    #     expect(result[:errors][1]).to eq({
    #       row: 1,
    #       col: 5,
    #       attribute: "proportion_rate",
    #       value: "proportion_late",
    #       message: "ヘッダの属性名が不正です。正しい属性名はproportion_rateです。"
    #     })
    #     expect(result[:errors][2]).to eq({
    #       row: 1,
    #       col: 6,
    #       attribute: "proportion_amount",
    #       value: "proportion_bmount",
    #       message: "ヘッダの属性名が不正です。正しい属性名はproportion_amountです。"
    #     })
    #   end
    # end

    context 'when ヘッダーが正常' do
      it "should be empty array when success" do
        expect(instance.validate_headers).to eq([])
      end
    end
  end

  describe '#make_preload' do
    let(:external_service) { create(:external_service) }
    let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }
    let(:external_service_transaction_type) {
      create(
        :external_service_transaction_type,
        external_service: external_service,
        transaction_type: transaction_type5
      )
    }

    before do
      external_service_transaction_type
    end

    it 'should be made preload.' do
      preload = instance.make_preload(address: addresses_eth)
      expect(preload[:address]).to eq(addresses_eth)
      expect(preload[:external_service_transaction_types]).to eq(addresses_eth.external_service_transaction_types)
    end
  end
end
