require 'rails_helper'

RSpec.describe "Unit", type: :feature do
  describe "#add_unit" do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction1) { create(:dollar_yen_transaction1, transaction_type: transaction_type1, address: addresses_eth) }

    context 'transaction kind is 1' do
      # 数量米ドル
      it "should get 預入 数量米ドル表示." do
        expect(Unit.add_unit(value: dollar_yen_transaction1.deposit_rate_on_screen, unit: Unit::EN_DOLLAR)).to eq('$106.59')
      end

      it "should get 預入 円換算表示." do
        expect(Unit.add_unit(value: dollar_yen_transaction1.deposit_en_screen, unit: Unit::JP_EN)).to eq('¥423')
      end

      it "should get 払出 数量米ドル." do
        expect(Unit.add_unit(value: dollar_yen_transaction1.withdrawal_rate_on_screen, unit: Unit::EN_DOLLAR)).to eq('')
      end

      it "should error." do
        expect { Unit.add_unit(value: dollar_yen_transaction1.deposit_en_screen, unit: 'hoge') }.to raise_error(Unit::NotFoundUnit)
      end
    end
  end
end
