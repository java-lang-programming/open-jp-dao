require 'rails_helper'

RSpec.describe "Fraction", type: :feature do
  describe "#en" do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction1) { create(:dollar_yen_transaction1, transaction_type: transaction_type1, address: addresses_eth) }

    context '端数処理の確認' do
      # 端数の処理についてはすべて切り捨て
      it "should get 11577." do
        expect(Fraction.en(value: '11577.16523')).to eq(11577)
      end

      it "should get nil." do
        expect(Fraction.en(value: nil)).to be nil
      end
    end
  end
end
