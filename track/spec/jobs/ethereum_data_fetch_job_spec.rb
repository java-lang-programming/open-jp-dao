require 'rails_helper'

RSpec.describe EthereumDataFetchJob, type: :job do
  let(:addresses_eth) { create(:addresses_eth) }
  let(:chain_id) { "1" }

  describe '失敗' do
    it 'should be success.'  do
      mock_apis_ens(
        status: 400,
        body:  { errors: { code: 'E0000001', message: 'chain_id error', detail: "detail" } }
      )
      EthereumDataFetchJob.perform_now(address_id: addresses_eth.id, chain_id: chain_id)

      address = Address.find(addresses_eth.id)
      expect(address.ens_name).to be nil
    end
  end

  describe '成功' do
    # ens_nameがあって取得した場合
    it 'should be saved ens_name.'  do
      mock_apis_ens(
        status: 200,
        body: { ens_name: "test.eth" }
      )
      EthereumDataFetchJob.perform_now(address_id: addresses_eth.id, chain_id: chain_id)

      address = Address.find(addresses_eth.id)
      expect(address.ens_name).to eq("test.eth")
    end

    # ens_nameを取得してもデータがない
    it 'should be saved ens_name.'  do
      mock_apis_ens(
        status: 200,
        body: { ens_name: nil }
      )
      EthereumDataFetchJob.perform_now(address_id: addresses_eth.id, chain_id: chain_id)

      address = Address.find(addresses_eth.id)
      expect(address.ens_name).to be nil
    end
  end
end
