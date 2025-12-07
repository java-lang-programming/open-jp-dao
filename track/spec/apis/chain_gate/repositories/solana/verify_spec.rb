require 'rails_helper'

RSpec.describe ChainGate::Repositories::Solana::Verify do
  let(:repo) { ChainGate::Repositories::Solana::Verify.new(params: params) }
  let(:public_key) { 'bbssssuuu' }
  let(:signature_b58) { 'aaaaaa' }
  let(:message) { 'message' }
  let(:params) { {
    public_key: public_key,
    signature_b58: signature_b58,
    message: message
  } }

  describe 'fetch' do
    let(:api_errors_response) {
      build(:api_errors_response, errors: [
        build(:api_error_response, code: "public_key error")
      ])
    }

    it 'ok' do
      mock_apis_solana_verify(
        status_code: 200,
        request_body: {
          public_key: public_key,
          signature_b58: signature_b58,
          message: message
        },
        body: { verified: true }
      )
      res = repo.fetch
      expect(res.status_code).to eq(200)
      expect(res.result).to eq({ "verified": true })
    end

    it 'unprocessable_content' do
      mock_apis_solana_verify(
        status_code: 422,
        request_body: {
          public_key: public_key,
          signature_b58: signature_b58,
          message: message
        },
        body: api_errors_response
      )
      res = repo.fetch
      expect(res.status_code).to eq(422)
      expect(res.result).to eq(api_errors_response)
    end

    it 'unauthorized' do
      mock_apis_solana_verify(
        status_code: 401,
        request_body: {
          public_key: public_key,
          signature_b58: signature_b58,
          message: message
        },
        body: api_errors_response
      )
      res = repo.fetch
      expect(res.status_code).to eq(401)
      expect(res.result).to eq(api_errors_response)
    end

    it 'internal server error' do
      mock_apis_solana_verify(
        status_code: 600,
        request_body: {
          public_key: public_key,
          signature_b58: signature_b58,
          message: message
        },
        body: api_errors_response
      )
      res = repo.fetch
      expect(res.status_code).to eq(500)
      expect(res.result).to eq({ errors: { code: ChainGate::Responses::Base::UNEXPECTED_ERROR_CODE } })
    end
  end
end
