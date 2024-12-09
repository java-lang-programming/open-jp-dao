class Session < ApplicationRecord
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
end
