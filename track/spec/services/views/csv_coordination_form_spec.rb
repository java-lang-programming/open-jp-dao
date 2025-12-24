require 'rails_helper'

RSpec.describe Views::CsvCoordinationForm do
  let(:csv_coordination_form) { described_class.new }

  describe 'initialize' do
    it 'should get form' do
      form_status = csv_coordination_form.form_status
      expect(form_status).to eq({
        name: { status: Views::Status::STATUS_READY, msg: nil }
      })
    end
  end

  describe 'execute' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }
    let(:name) { '利子' }

    it 'should get all attributes errors.' do
      # 保存データ
      external_service_transaction_type = transaction_type5.build_external_service_transaction_type
      external_service_transaction_type.valid?
      csv_coordination_form.execute(external_service_transaction_type: external_service_transaction_type)
      form_status = csv_coordination_form.form_status

      expect(form_status[:name]).to eq({ status: Views::Status::STATUS_FAILURE, msg: "内容を入力してください" })
    end

    it 'should be not error.' do
      # 保存データ
      external_service_transaction_type = transaction_type5.build_external_service_transaction_type
      external_service_transaction_type.name = name
      external_service_transaction_type.valid?

      csv_coordination_form.execute(external_service_transaction_type: external_service_transaction_type)
      form_status = csv_coordination_form.form_status

      expect(form_status[:name]).to eq({ status: Views::Status::STATUS_COMPLETE, msg: nil })
    end
  end
end
