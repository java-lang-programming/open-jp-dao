require 'rails_helper'

RSpec.describe Ledger, type: :model do
  let(:addresses_eth) { create(:addresses_eth) }
  let(:ledger_item_1) { create(:ledger_item_1) }
  let(:ledger_item_2) { create(:ledger_item_2) }

  describe 'calculate_recorded_amount' do
    # 按分なし
    it 'should get recorded_amount.' do
      ledger = Ledger.build(
        address: addresses_eth,
        date: Date.new(2025, 3, 4),
        name: 'MFクラウド',
        ledger_item: ledger_item_1,
        face_value: 3696,
        proportion_rate: nil,
        proportion_amount: nil
      )
      # 2025/03/04,通信費,MFクラウド,3696,,
      # 　これを実装する
      recorded_amount = ledger.calculate_recorded_amount
      expect(recorded_amount).to eq(BigDecimal(3696))
    end
    # 　按分あり
    it 'should get recorded_amount.' do
      # 水道光熱費	ENEOS電気	1/27	9333		0.2	1866.6
      ledger = Ledger.build(
        address: addresses_eth,
        date: Date.new(2025, 1, 27),
        name: 'ENEOS電気',
        ledger_item: ledger_item_2,
        face_value: 9333,
        proportion_rate: BigDecimal('0.2'),
        proportion_amount: nil
      )
      recorded_amount = ledger.calculate_recorded_amount
      expect(recorded_amount).to eq(1866)
    end

    # 　按分比率と追加削除あり
    it 'should get recorded_amount.' do
      # 通信費	enひかり	1/27	5643	825	0.8	3854.4
      ledger = Ledger.build(
        address: addresses_eth,
        date: Date.new(2025, 1, 27),
        name: '通信費',
        ledger_item: ledger_item_1,
        face_value: 5643,
        proportion_rate: BigDecimal('0.8'),
        proportion_amount: BigDecimal('825'),
      )
      recorded_amount = ledger.calculate_recorded_amount
      expect(recorded_amount).to eq(3854)
    end
  end
end
