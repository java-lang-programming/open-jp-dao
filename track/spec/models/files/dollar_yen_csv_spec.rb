require 'rails_helper'

# https://github.com/willnet/rspec-style-guide

RSpec.describe Files::DollarYenCsv, type: :model do
  describe 'date_errors' do
    context 'success' do
      it 'should get no error when date is valid.' do
        row = [ "2024/08/01", "149.62" ]
        csv = Files::DollarYenCsv.new(
          row_num: 2,
          row: row
        )

        errors = []
        errors = csv.date_errors(errors: errors)
        expect(errors).to eq([])
      end
    end

    context 'errors' do
      it 'should get error date is empty.' do
        row = [ "", "149.22" ]
        csv = Files::DollarYenCsv.new(
          row_num: 2,
          row: row
        )

        errors = []
        errors = csv.date_errors(errors: errors)
        expect(errors).to eq([ "2行目のdateが入力されていません" ])
      end

      it 'should get error date is invalid.' do
        row = [ "aaa/bb/cc", "149.22" ]
        csv = Files::DollarYenCsv.new(
          row_num: 2,
          row: row
        )

        errors = []
        errors = csv.date_errors(errors: errors)
        expect(errors).to eq([ "2行目のdateの値が不正です。yyyy/mm/dd形式で正しい日付を入力してください" ])
      end
    end
  end

  describe 'dollar_yen_nakane_errors' do
    context 'success' do
      it 'should get no error when dollar_yen_nakane is valid.' do
        row = [ "2024/08/01", "149.62" ]
        csv = Files::DollarYenCsv.new(
          row_num: 2,
          row: row
        )

        errors = []
        errors = csv.dollar_yen_nakane_errors(errors: errors)
        expect(errors).to eq([])
      end
    end

    context 'success' do
      it 'should get no error when dollar_yen_nakane is valid.' do
        row = [ "2024/08/01", "aaaa" ]
        csv = Files::DollarYenCsv.new(
          row_num: 2,
          row: row
        )

        errors = []
        errors = csv.dollar_yen_nakane_errors(errors: errors)
        expect(errors).to eq([ "2行目のdollar_yen_nakaneの値が不正です。数値、もしくは小数点付きの数値を入力してください" ])
      end

      it 'should get no error when dollar_yen_nakane is valid.' do
        row = [ "2024/08/01", "" ]
        csv = Files::DollarYenCsv.new(
          row_num: 2,
          row: row
        )

        errors = []
        errors = csv.dollar_yen_nakane_errors(errors: errors)
        expect(errors).to eq([ "2行目のdollar_yen_nakaneが入力されていません" ])
      end
    end
  end

  describe 'valid_errors' do
    context 'success' do
      it 'should get no error when date and dollar_yen_nakane are valid.' do
        row = [ "2024/08/01", "149.62" ]
        csv = Files::DollarYenCsv.new(
          row_num: 2,
          row: row
        )

        errors = []
        errors = csv.valid_errors
        expect(errors).to eq([])
      end
    end

    context 'failure' do
      it 'should get no error when date is valid.' do
        row = [ "aaaa/bb/cc", "149.62" ]
        csv = Files::DollarYenCsv.new(
          row_num: 2,
          row: row
        )

        errors = []
        errors = csv.valid_errors
        expect(errors).to eq([ "2行目のdateの値が不正です。yyyy/mm/dd形式で正しい日付を入力してください" ])
      end
    end
  end

  describe 'unique_key' do
    it 'should get unique_key.' do
      row = [ "2024/08/01", "149.62" ]
      csv = Files::DollarYenCsv.new(
        row_num: 2,
        row: row
      )
      expect(csv.unique_key).to eq("2024/08/01")
    end
  end

  describe 'unique_key_hash' do
    let(:addresses_eth) { create(:addresses_eth) }

    it 'should get unique_key_hash.' do
      h = {}
      row = [ "2024/08/01", "149.62" ]
      csv = Files::DollarYenCsv.new(row_num: 2, row: row)
      h = csv.unique_key_hash(unique_key_hash: h)
      csv = Files::DollarYenCsv.new(row_num: 4, row: row)
      h = csv.unique_key_hash(unique_key_hash: h)

      expect(h).to eq({ "2024/08/01"=>{ rownums: [ 2, 4 ] } })
    end
  end
end
