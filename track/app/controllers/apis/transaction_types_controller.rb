class Apis::TransactionTypesController < ApplicationController
  before_action :verify_v2, only: [ :index ]

  def index
    session = find_session_by_cookie
    address = Address.where(address: session.address.address).first
    base_transaction_types = TransactionType.where(address_id: address.id)

    total = base_transaction_types.count

    responses = base_transaction_types.map do |o|
      {
        id: o.id,
        name: o.name,
        kind: o.kind_before_type_cast,
        kind_name: o.kind_name
      }
    end

    render json: { total: total, transaction_types: responses }, status: :ok
  end

  # def create

  # end
end

# apis_transaction_type
