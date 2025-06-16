require 'rails_helper'

RSpec.describe ChainGate::Repositories::Sessions::Verify do
  let(:repo) { ChainGate::Repositories::Sessions::Verify.new(params: {}) }

  describe 'fetch' do
    it 'should get data when fetch is success' do
      mock_apis_verify_custom(
        status: 201,
        body: {}
      )
      res = repo.fetch
      expect(res.status_code).to eq(201)
    end

    it 'should get error when fetch is 400' do
      mock_apis_verify_custom(
        status: 400,
        body: { errors: { code: 'E0000001', message: 'chain_id error', detail: "detail" } }
      )
      res = repo.fetch
      expect(res.status_code).to eq(400)
    end

    it 'should get error when fetch is 403' do
      mock_apis_verify_custom(
        status: 403,
        body:  { errors: { code: 'E0000002', message: 'イーサリアムに接続できませんでした', detail: "接続先のステータスを確認してください" } }
      )
      res = repo.fetch
      expect(res.status_code).to eq(403)
    end

    it 'should get error when fetch is 500' do
      mock_apis_verify_custom(
        status: 500,
        body: nil
      )
      res = repo.fetch
      expect(res.status_code).to eq(500)
    end
  end
end
