require 'rails_helper'

RSpec.describe FileUploads::DollarYenTransactionDepositCsv, type: :feature do
  # let(:addresses_eth) { create(:addresses_eth) }
  # let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }

  describe 'deposit?' do
    let(:addresses_eth) { create(:addresses_eth) }
    let(:transaction_type1) { create(:transaction_type1, address: addresses_eth) }
    let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }
    let(:dollar_yen_transaction1) { create(:dollar_yen_transaction1, transaction_type: transaction_type1, address: addresses_eth) }
    let(:dollar_yen_transaction44) { create(:dollar_yen_transaction44, transaction_type: transaction_type5, address: addresses_eth) }
    let(:error_deposit_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_transaction_deposit_csv/error_deposit.csv" }

    context 'validation_errors' do
      it 'should be true.' do
        transaction_type1
        transaction_type5
        service = FileUploads::DollarYenTransactionDepositCsv.new(address_id: addresses_eth.id, file: error_deposit_csv_path)
        errors = service.validation_errors
        expect(service.validation_errors).to eq([
          { msg: [ "2行目のdateが入力されていません" ] },
          { msg: [ "3行目のdateの値が不正です。yyyy/mm/dd形式で正しい日付を入力してください", "3行目のtransaction_typeが入力されていません" ] },
          { msg: [ "4行目のdeposit_quantityの値が不正です。数値、もしくは小数点付きの数値を入力してください" ] },
          { msg: [ "5行目のdeposit_rateが入力されていません" ] },
          { msg: [ "6行目のdeposit_rateの値が不正です。数値、もしくは小数点付きの数値を入力してください" ] }
        ])
      end
    end
  end
end
