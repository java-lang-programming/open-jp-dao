class Session < ApplicationRecord
  ETHEREUM_SEPOLIA = 11155111
  ETHEREUM_MAINNET = 1
  POLYGON_MAINNET = 137
  # belongs_to :user
  belongs_to :address

  validates :chain_id, numericality: true
  validates :message, presence: true
  validates :signature, presence: true
  validates :domain, presence: true

  def make_verify_params(nonce:)
    {
      chain_id: chain_id,
      message: message,
      signature: signature,
      nonce: nonce,
      domain: domain
    }
  end

  # https://chainlist.org/
  def network
    return "Ethereum Sepolia" if chain_id == Session::ETHEREUM_SEPOLIA
    return "Ethereum Mainnet" if chain_id == Session::ETHEREUM_MAINNET
    return "Polygon Mainnet" if chain_id == Session::POLYGON_MAINNET
    # return "Base" if chain_id == 8453
    ""
  end

  def last_login
    created_at.strftime("%Y/%m/%d %H:%M:%S")
  end

  def preload_records
    { address: address, transaction_types: address.transaction_types }
  end
end
