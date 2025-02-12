require 'rails_helper'

RSpec.describe DollarYen, type: :model do
  describe 'formatted_date' do
    let(:dollar_yen_20241218) { create(:dollar_yen_20241218) }

    context '日付をformatする' do
      it 'should get default format string date.' do
        expect(dollar_yen_20241218.formatted_date).to eq("2024/12/18")
      end
    end
  end

  describe 'formatted_dollar_yen_nakane' do
    let(:dollar_yen_20241218) { create(:dollar_yen_20241218) }

    context 'ドル円を取得する' do
      it 'should get formatted_dollar_yen_nakane.' do
        expect(dollar_yen_20241218.formatted_dollar_yen_nakane).to eq(153.74)
      end
    end
  end
end
