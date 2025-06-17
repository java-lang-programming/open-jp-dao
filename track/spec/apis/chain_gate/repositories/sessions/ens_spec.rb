require 'rails_helper'

RSpec.describe ChainGate::Repositories::Sessions::Ens do
  let(:repo) { ChainGate::Repositories::Sessions::Ens.new(
    chain_id: 1, address: "aaaaa")
  }

  describe 'path' do
    it 'should get path.' do
      expect(repo.path).to eq("/api/ethereum/1/address/aaaaa/ens")
    end
  end

  describe 'fetch' do
    it 'should get data when fetch is success' do
      mock_apis_ens(
        status: 200,
        body: { ens_name: "test.eth" }
      )
      status, res = repo.fetch.result
      expect(status).to eq(200)
      expect(res).to eq({ ens_name: "test.eth" })
    end

    it 'should get error when fetch is 400' do
      mock_apis_ens(
        status: 400,
        body:  { errors: { code: 'E0000001', message: 'chain_id error', detail: "detail" } }
      )
      status, res = repo.fetch.result
      expect(status).to eq(400)
      expect(res).to eq({ errors: { code: 'E0000001', message: 'chain_id error', detail: "detail" } })
    end

    it 'should get error when fetch is 403' do
      mock_apis_ens(
        status: 403,
        body:  { errors: { code: 'E0000002', message: 'イーサリアムに接続できませんでした', detail: "接続先のステータスを確認してください" } }
      )
      status, res = repo.fetch.result
      expect(status).to eq(403)
      expect(res).to eq({ errors: { code: 'E0000002', message: 'イーサリアムに接続できませんでした', detail: "接続先のステータスを確認してください" } })
    end

    it 'should get error when fetch is 500' do
      mock_apis_ens(
        status: 500,
        body: nil
      )
      status, res = repo.fetch.result
      expect(status).to eq(500)
      expect(res).to eq({ errors: { code: "ERR-NOT-IMPLEMENTED" } })
    end
  end
end
