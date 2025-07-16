class EthereumDataFetchJob < ApplicationJob
  queue_as :ethereum

  class ENSFetchError < StandardError; end

  def perform(address_id:, chain_id:)
    begin
      address = Address.find(address_id)
      ens_response = address.fetch_ens(chain_id: chain_id)

      status, res = ens_response.result
      if status != 200
        raise ENSFetchError
      end

      address.ens_name = res[:ens_name]
      address.save
    rescue => e
      Rails.error.report(e)
    end
  end
end
