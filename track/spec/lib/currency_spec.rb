require 'rails_helper'

RSpec.describe Currency, type: :lib do
  describe "#en_with_unit" do
    context '端数処理の確認' do
      # 端数の処理についてはすべて切り捨て
      it "should get ¥11,577." do
        expect(Currency.en_with_unit(value: '11577.16523')).to eq('¥11,577')
      end

      # 端数の処理についてはすべて切り捨て(.9でも四捨五入しない)
      it "should get ¥11,577." do
        expect(Currency.en_with_unit(value: '11577.999')).to eq('¥11,577')
      end

      # 3桁ならカンマなし
      it "should get ¥900." do
        expect(Currency.en_with_unit(value: '900.999')).to eq('¥900')
      end
    end

    it "should get nil." do
      expect(Currency.en_with_unit(value: nil)).to be nil
    end
  end

  describe "#dollar_with_unit" do
    # 端数の処理についてはすべて切り捨て
    it "should get 11,577.16." do
      expect(Currency.dollar_with_unit(value: '11577.16523')).to eq('$11,577.16')
    end

    # 3桁ならカンマなし
    it "should get ¥900." do
      expect(Currency.dollar_with_unit(value: '900.999')).to eq('$900.99')
    end

    it "should get nil." do
      expect(Currency.dollar_with_unit(value: nil)).to be nil
    end
  end
end
