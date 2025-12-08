class Session < ApplicationRecord
  ETHEREUM_SEPOLIA = 11155111
  ETHEREUM_MAINNET = 1
  SOLANA = nil
  # belongs_to :user
  belongs_to :address

  validates :chain_id, numericality: true, allow_nil: true
  validates :message, presence: true
  validates :signature, presence: true
  # Ethereum の場合だけ domain を必須
  validates :domain, presence: true, if: :ethereum_chain?

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
    # TODO 接続チェーンはここでは(表記)判断しない
    return "Sepolia" if chain_id == Session::ETHEREUM_SEPOLIA
    return "Ethereum Mainnet" if chain_id == Session::ETHEREUM_MAINNET
    return "Solana" if chain_id == Session::SOLANA
    ""
  end

  def last_login
    created_at.strftime("%Y/%m/%d %H:%M:%S")
  end

  def preload_records
    { address: address, transaction_types: address.transaction_types }
  end

  private

  def ethereum_chain?
    chain_id.in?([ Session::ETHEREUM_MAINNET, Session::ETHEREUM_SEPOLIA ])
  end
end
