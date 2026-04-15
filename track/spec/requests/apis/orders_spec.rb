require 'rails_helper'


RSpec.describe Apis::OrdersController, type: :request do
  let(:addresses_eth) { create(:addresses_eth) }
  let(:payment_jpyc) { create(:payment_jpyc) }
  let(:product) { create(:product, price: 5000) }
  let(:product_id) { product.id }

  describe '#create' do
    context 'ログイン情報なし' do
      it "returns http success" do
        post apis_orders_path, params: { product_id: product_id, payment_id: payment_jpyc.id }
        expect(response.status).to eq 401
        expect(JSON.parse(response.body)).to eq({ "errors" => [ { "msg" => "権限がありません" } ] })
      end
    end

    context 'when ログイン情報あり' do
      before do
        sign_in_as(address_record: addresses_eth)
      end

      context '正常系' do
        before do
          payment_jpyc
        end
        it '作成が成功すること' do
          post apis_orders_path, params: { product_id: product_id, payment_id: payment_jpyc.id }
          expect(response.status).to eq 201
          expect(JSON.parse(response.body)['id']).not_to be nil

          # 登録されたorderの値の確認
          order = addresses_eth.orders.first
          expect(order.price).to eq(product.price)
          expect(order.status).to eq("pending")
        end
      end

      context '異常系' do
        it 'バリデーションエラーが発生すること' do
          post apis_orders_path, params: { product_id: '', payment_id: 1 }
          expect(response.status).to eq 422
          expect(JSON.parse(response.body)['errors']).not_to be nil
        end
      end
    end
  end
end
