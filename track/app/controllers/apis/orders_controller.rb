class Apis::OrdersController < ApplicationController
  def create
    session = find_session_by_cookie
    unless session.present?
      render json: { errors: [ { msg: "権限がありません" } ] }, status: :unauthorized
      return
    end

    order = Order.new(order_params)
    order.address = session.address
    order.generate_uuid
    order.copy_product_price

    if order.save
      render json: { id: order.id }, status: :created
    else
      render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def order_params
    params.permit(:product_id, :payment_id)
  end
end
