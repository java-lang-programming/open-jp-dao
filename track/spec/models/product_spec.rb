require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'Enum' do
    it '正しいステータス定義を持っていること' do
      expect(Product.statuses.keys).to match_array(%w[draft scheduled active limited sold_out archived])
    end
  end

  describe 'Scopes' do
    describe '.published' do
      let!(:active_published) { create(:product, status: :active, published_at: 1.day.ago) }
      let!(:scheduled_published) { create(:product, status: :scheduled, published_at: 1.hour.ago) }
      let!(:future_scheduled) { create(:product, status: :scheduled, published_at: 1.day.from_now) }
      let!(:draft_product) { create(:product, status: :draft, published_at: 1.day.ago) }
      let!(:nil_published_at) { create(:product, status: :active, published_at: nil) }
      let!(:limited_product) { create(:product, status: :limited, published_at: 1.day.ago) }

      it '公開中の商品（active/scheduled かつ published_at が過去）のみを返すこと' do
        expect(Product.published).to include(active_published, scheduled_published)
        expect(Product.published).not_to include(future_scheduled, draft_product, nil_published_at, limited_product)
      end
    end
  end

  describe 'Destruction dependency' do
    it '注文がある商品は、物理削除しようとするとエラーが発生すること' do
      product = create(:product)
      address = create(:addresses_eth)
      payment = create(:payment)
      create(:order, product: product, address: address, payment: payment)
      # DBの制約によって守られていることを検証
      expect { product.destroy }.to raise_error(ActiveRecord::InvalidForeignKey)
    end
  end

  # describe 'Callbacks' do
  #   describe '#set_published_at_if_active' do
  #     context 'ステータスを active に変更した場合' do
  #       let(:product) { create(:product, status: :draft, published_at: nil) }
  #
  #       it 'published_at が nil なら現在時刻が設定されること' do
  #         expect {
  #           product.update(status: :active)
  #         }.to change { product.published_at }.from(nil).to(be_within(1.second).of(Time.current))
  #       end
  #
  #       it 'すでに published_at が設定されている場合は上書きされないこと' do
  #         existing_time = 1.day.ago
  #         product.update(published_at: existing_time)
  #
  #         expect {
  #           product.update(status: :active)
  #         }.not_to change { product.published_at }
  #       end
  #     end
  #
  #     context 'ステータスを active 以外に変更した場合' do
  #       let(:product) { create(:product, status: :draft, published_at: nil) }
  #
  #       it 'published_at は nil のままであること' do
  #         expect {
  #           product.update(status: :scheduled)
  #         }.not_to change { product.published_at }
  #       end
  #     end
  #   end
  # end
end
