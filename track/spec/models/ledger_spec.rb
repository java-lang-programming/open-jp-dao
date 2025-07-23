require 'rails_helper'

RSpec.describe Ledger, type: :model do
  let(:addresses_eth) { create(:addresses_eth) }
  let(:ledger_item_1) { create(:ledger_item_1) }
  let(:ledger_item_2) { create(:ledger_item_2) }

  describe 'valid' do
    # date
    context 'date' do
      # dateが必須であることのテスト
      it 'dateがない場合は無効であること' do
        model = Ledger.new(date: nil)
        expect(model).to_not be_valid
        expect(model.errors[:date].size).to eq(1)
        expect(model.errors[:date][0]).to eq("を入力してください")
      end
    end


    context 'name' do
      # nameが必須であることのテスト
      it 'nameがない場合は無効であること' do
        model = Ledger.new(name: nil)
        expect(model).to_not be_valid
        expect(model.errors[:name].size).to eq(2)
        expect(model.errors[:name][0]).to eq("を入力してください")
      end

      # nameが1文字未満の場合は無効であることのテスト
      it 'nameが1文字未満の場合は無効であること' do
        model = Ledger.new(name: "")
        expect(model).to_not be_valid
        expect(model.errors[:name].size).to eq(2)
        expect(model.errors[:name][0]).to eq("を入力してください")
      end

      # nameが50文字を超える場合は無効であることのテスト
      it 'nameが50文字を超える場合は無効であること' do
        model = Ledger.new(name: "a" * 51) # 51文字の文字列
        expect(model).to_not be_valid
        expect(model.errors[:name].size).to eq(1)
        expect(model.errors[:name][0]).to eq("は50文字以内で入力してください")
      end

      # nameが1文字以上50文字以内の場合は有効であることのテスト
      it 'nameが1文字以上50文字以内の場合は有効であること' do
        model = Ledger.new(date: '2020-01-01', name: "有効な名前", face_value: 100, ledger_item: ledger_item_1, address: addresses_eth)
        expect(model).to be_valid

        model = Ledger.new(date: '2020-1-1', name: "a", face_value: 100, ledger_item: ledger_item_1, address: addresses_eth) # 1文字
        expect(model).to be_valid

        model = Ledger.new(date: '2020-1-1', name: "a" * 50, face_value: 100, ledger_item: ledger_item_1, address: addresses_eth) # 50文字
        expect(model).to be_valid
      end
    end

    context 'face_value' do
      # face_valueが必須であることのテスト
      it 'face_valueがない場合は無効であること' do
        model = Ledger.new(date: '2020-1-1', name: "有効な名前", face_value: nil, ledger_item: ledger_item_1, address: addresses_eth)
        expect(model).to_not be_valid
        expect(model.errors[:face_value].size).to eq(2)
        expect(model.errors[:face_value][0]).to eq("を入力してください")
      end

      # face_valueが整数でない場合は無効であることのテスト
      it 'face_valueが整数でない場合は無効であること' do
        model = Ledger.new(date: '2020-1-1', name: "有効な名前", face_value: 10.5, ledger_item: ledger_item_1, address: addresses_eth) # 浮動小数点数
        expect(model).to_not be_valid
        expect(model.errors[:face_value].size).to eq(1)
        expect(model.errors[:face_value][0]).to eq("は整数で入力してください")

        model = Ledger.new(date: '2020-1-1', name: "有効な名前", face_value: "abc", ledger_item: ledger_item_1, address: addresses_eth) # 文字列
        expect(model).to_not be_valid
        expect(model.errors[:face_value].size).to eq(1)
        expect(model.errors[:face_value][0]).to eq("は数値で入力してください")
      end
    end

    context 'proportion_rate' do
      # proportion_rateがnilの場合は有効であることのテスト（任意入力）
      it 'proportion_rateがnilの場合は有効であること' do
        model = Ledger.new(date: '2020-1-1', name: "有効な名前", face_value: 1000, proportion_rate: nil, ledger_item: ledger_item_1, address: addresses_eth)
        expect(model).to be_valid
      end

      # proportion_rateが小数点以下3桁以上の場合は無効であることのテスト
      it 'proportion_rateが小数点以下3桁以上の場合は無効であること' do
        model = Ledger.new(date: '2020-1-1', name: "有効な名前", face_value: 1000, proportion_rate: 0.123, ledger_item: ledger_item_1, address: addresses_eth)
        model.valid?
        expect(model).to_not be_valid
        expect(model.errors[:proportion_rate][0]).to eq("は小数点以下2桁以内で入力してください")
      end

      # proportion_rateが小数点以下2桁以内の場合は有効であることのテスト
      it 'proportion_rateが小数点以下2桁以内の場合は有効であること' do
        model = Ledger.new(date: '2020-1-1', name: "有効な名前", face_value: 1000, proportion_rate: 0.12, ledger_item: ledger_item_1, address: addresses_eth)
        expect(model).to be_valid

        model = Ledger.new(date: '2020-1-1', name: "有効な名前", face_value: 1000, proportion_rate: 1.0, ledger_item: ledger_item_1, address: addresses_eth)
        expect(model).to be_valid

        model = Ledger.new(date: '2020-1-1', name: "有効な名前", face_value: 1000, proportion_rate: 100, ledger_item: ledger_item_1, address: addresses_eth) # 整数も有効
        expect(model).to be_valid

        model = Ledger.new(date: '2020-1-1', name: "有効な名前", face_value: 1000, proportion_rate: 0.0, ledger_item: ledger_item_1, address: addresses_eth)
        expect(model).to be_valid
      end
    end

    context 'proportion_amount' do
      # proportion_amountがnilの場合は有効であることのテスト（任意入力）
      it 'proportion_amountがnilの場合は有効であること' do
        model = Ledger.new(date: '2020-1-1', name: "有効な名前", face_value: 1000, proportion_rate: nil, proportion_amount: nil, ledger_item: ledger_item_1, address: addresses_eth)
        expect(model).to be_valid
      end

      # proportion_amountが整数の場合は有効であることのテスト
      it 'proportion_amountがnilの場合は有効であること' do
        model = Ledger.new(date: '2020-1-1', name: "有効な名前", face_value: 1000, proportion_rate: nil, proportion_amount: 1000, ledger_item: ledger_item_1, address: addresses_eth)
        expect(model).to be_valid
      end

      # proportion_amountが整数でない場合は無効であることのテスト
      it 'proportion_amountが整数でない場合は無効であること' do
        model = Ledger.new(date: '2020-1-1', name: "有効な名前", face_value: 10.5, proportion_rate: nil, proportion_amount: 10.5, ledger_item: ledger_item_1, address: addresses_eth) # 浮動小数点数
        expect(model).to_not be_valid
        expect(model.errors[:proportion_amount].size).to eq(1)
        expect(model.errors[:proportion_amount][0]).to eq("は整数で入力してください")
      end
    end
  end

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

    # 按分あり
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

    # 按分比率と追加削除あり
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
