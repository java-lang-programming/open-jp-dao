class Apis::Orders::PaymentsController < ApplicationController
  def create
    session = find_session_by_cookie
    unless session.present?
      render json: { errors: [ { msg: "権限がありません" } ] }, status: :unauthorized
      return
    end

    # params = params.permit(:tx_hash)

    # to_addressをAPIから取得する

    order = session.address.orders.where(id: params[:order_id]).first

    if order.nil?
      render json: { errors: [ { msg: "注文情報が存在しません" } ] }, status: :not_found
      return
    end

    unless order.pending?
      render json: { errors: [ { msg: "指定した注文データは決済処理が完了しています" } ] }, status: :bad_request
      return
    end

    blockchain_order = order.build_blockchains_order(
      chain_id: session.chain_id,
      tx_hash: params[:tx_hash],
      from_address: session.address.address
    )

    render status: :created
  end
end
