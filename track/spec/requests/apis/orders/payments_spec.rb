require 'rails_helper'

RSpec.describe Apis::Orders::PaymentsController, type: :request do
  let(:addresses_eth) { create(:addresses_eth) }
  let(:payment_jpyc) { create(:payment_jpyc) }
  let(:product) { create(:product, price: 5000) }
  let(:order) { create(:order, product: product, address: addresses_eth, payment: payment_jpyc) }
  let(:product_id) { product.id }
  let(:tx_hash) { 'aaassdsdsere23ddrsdcs8ekjefa8yxkj' }

  describe "#create" do
    context 'when ログイン情報なし' do
      it "returns http success" do
        post apis_order_payments_path(order), params: { tx_hash: tx_hash }
        expect(response.status).to eq 401
        expect(JSON.parse(response.body)).to eq({ "errors" => [ { "msg" => "権限がありません" } ] })
      end
    end

    context 'when ログイン情報あり' do
      before do
        sign_in_as(address_record: addresses_eth)
      end

      context '異常系' do
        context 'order情報がない' do
          it 'should not found.' do
            post apis_order_payments_path(order_id: order.id + 1), params: { tx_hash: tx_hash }
            expect(response.status).to eq 404
            expect(JSON.parse(response.body)).to eq({ "errors" => [ { "msg" => "注文情報が存在しません" } ] })
          end
        end

        context '決済処理がpendingでない' do
          let(:order) {
            create(:order, product: product, address: addresses_eth, payment: payment_jpyc, status: :completed)
          }
          it 'should not found.' do
            post apis_order_payments_path(order), params: { tx_hash: tx_hash }
            expect(response.status).to eq 400
            expect(JSON.parse(response.body)).to eq({ "errors" => [ { "msg" => "指定した注文データは決済処理が完了しています" } ] })
          end
        end
      end

      context '正常系' do
        it '作成が成功すること' do
          post apis_order_payments_path(order), params: { tx_hash: tx_hash }
          expect(response.status).to eq 201
        end
      end
    end
  end
end
