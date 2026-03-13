require 'rails_helper'

RSpec.describe Setting, type: :model do
  describe 'バリデーションの検証' do
    let(:addresses_eth) { create(:addresses_eth, :with_setting, ens_name: 'test.eth') }
    let(:setting) { addresses_eth.setting }

    it '適切な年度であれば有効であること' do
      setting.default_year = 2025
      expect(setting).to be_valid
    end

    it '2000未満は無効であること' do
      setting.default_year = 1999
      expect(setting).to_not be_valid
    end

    it '2100より大きい場合は無効であること' do
      setting.default_year = 2101
      expect(setting).to_not be_valid
    end

    it '数値以外（文字列など）は無効であること' do
      setting.default_year = 'aaaa'
      expect(setting).to_not be_valid
    end

    it '空欄は無効であること' do
      setting.default_year = nil
      expect(setting).to_not be_valid
    end
  end
end
