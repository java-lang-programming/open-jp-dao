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
      stub_request(:get, %r{/api/ethereum/\d+/address/[a-zA-Z0-9]+/ens}).to_return(
        status: 200,
        body: { ens_name: "test.eth" }.to_json,
        headers: {
          "Cache-Control" => "public, max-age=86400"
        }
      )
      status, res = repo.fetch.result
      expect(status).to eq(200)
      expect(res).to eq({ ens_name: "test.eth" })
    end

    it 'should get error when fetch is 400' do
      # {'errors': {'code': 'E0000001', 'message': 'chain_id error', 'detail': "ExceptionInvalidChainID('invalid chain id. chain id must be 1 or 8545 or 11155111')"}
      stub_request(:get, %r{/api/ethereum/\d+/address/[a-zA-Z0-9]+/ens}).to_return(
        status: 400,
        body: { errors: { code: 'E0000001', message: 'chain_id error', detail: "detail" } }.to_json,
        headers: {
          "Cache-Control" => "public, max-age=86400"
        }
      )
      status, res = repo.fetch.result
      expect(status).to eq(400)
      expect(res).to eq({ errors: { code: 'E0000001', message: 'chain_id error', detail: "detail" } })
    end

    it 'should get error when fetch is 403' do
      stub_request(:get, %r{/api/ethereum/\d+/address/[a-zA-Z0-9]+/ens}).to_return(
        status: 403,
        body: { errors: { code: 'E0000002', message: 'イーサリアムに接続できませんでした', detail: "接続先のステータスを確認してください" } }.to_json,
        headers: {
          "Cache-Control" => "public, max-age=86400"
        }
      )
      status, res = repo.fetch.result
      expect(status).to eq(403)
      expect(res).to eq({ errors: { code: 'E0000002', message: 'イーサリアムに接続できませんでした', detail: "接続先のステータスを確認してください" } })
    end

    it 'should get error when fetch is 500' do
      stub_request(:get, %r{/api/ethereum/\d+/address/[a-zA-Z0-9]+/ens}).to_return(
        status: 500,
        body: nil,
        headers: {
          "Cache-Control" => "public, max-age=86400"
        }
      )
      status, res = repo.fetch.result
      expect(status).to eq(500)
      expect(res).to eq({ errors: { code: "ERR-NOT-IMPLEMENTED" } })
    end
  end
end
