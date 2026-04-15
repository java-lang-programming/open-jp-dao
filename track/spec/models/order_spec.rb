require 'rails_helper'

RSpec.describe Order, type: :model do
  let(:product) { create(:product, price: 5000) }
  let(:address) { create(:addresses_eth) }
  let(:payment) { create(:payment_jpyc) }

  describe 'Destruction safety' do
    it '決済データ(BlockchainOrder)が存在する注文は、削除できないこと' do
      order = create(:order, product: product, address: address, payment: payment)
      create(:blockchains_order, order: order)

      # 戻り値が false ではなく、例外が飛んでくることを検証
      expect { order.destroy }.to raise_error(ActiveRecord::InvalidForeignKey)
    end
  end

  describe '#generate_uuid' do
    it 'uuidが生成されること' do
      order = build(:order, product: product, address: address, payment: payment, uuid: nil)
      order.generate_uuid
      expect(order.uuid).to be_present
      expect(order.uuid.length).to eq 36 # UUIDの標準的な長さ
    end
  end

  describe '#copy_product_price' do
    it '注文作成時に商品の価格が正しくコピーされること' do
      order = build(:order, product: product, address: address, payment: payment, price: nil)
      order.copy_product_price
      expect(order.price).to eq product.price
    end

    # 商品の値上げ前に購入した場合、注文ずみの値段は変わらない
    it '価格コピー後、商品の価格が変わっても注文価格は維持されること' do
      before_price = product.price
      order = create(:order, product: product, address: address, payment: payment, price: 100)
      order.copy_product_price
      order.save!

      # 商品の価格を値上げする
      product.update!(price: 9999)

      # 注文側の価格は 前のままであるべき
      expect(order.reload.price).to eq before_price
    end
  end

  describe '#mark_as_completed!' do
    let(:order) { build(:order, product: product, address: address, payment: payment) }
    it 'ステータスを completed に更新できること' do
      expect { order.mark_as_completed! }.to change { order.status }.from('pending').to('completed')
    end
  end

  describe '#mark_as_failed!' do
    let(:order) { build(:order, product: product, address: address, payment: payment) }
    it 'ステータスを failed に更新できること' do
      expect { order.mark_as_failed! }.to change { order.status }.from('pending').to('failed')
    end
  end
end
