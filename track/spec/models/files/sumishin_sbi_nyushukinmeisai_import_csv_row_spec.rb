require 'rails_helper'

RSpec.describe Files::SumishinSbiNyushukinmeisaiImportCsvRow do
  let(:addresses_eth) { create(:addresses_eth) }
  let(:master) { FileUploads::GenerateMaster.new(
    kind: FileUploads::GenerateMaster::SUMISHIN_SBI_NYUSHUKINMEISAI).master
  }
  let(:preload) {
    {
      address: addresses_eth,
      external_service_transaction_types: addresses_eth.external_service_transaction_types
    }
  }
  let(:row_num) { 1 }
  let(:ledger_item_1) {
    create(:ledger_item_1)
  }
  let(:dollar_yen_20251001) { create(:dollar_yen_20251001) }
  # ドル→円にして変換した場合のデータ
  let(:row) {
    [ '2025/10/01', '普通　米ドル　円に変換', '85', nil, '501.89', '-' ]
  }
  let(:instance) {
    described_class.new(
      master: master,
      row_num: row_num,
      row: row,
      preload: preload
    )
  }

  describe '#to_dollar_yen_transaction' do
    it 'should get ledger_item index.' do
      dollar_yen_transaction = instance.to_dollar_yen_transaction
      expect(dollar_yen_transaction).to eq([ '2025/10/01', '普通　米ドル　円に変換' ])
    end

    context 'when 外部連携あり' do
      let(:external_service) { create(:external_service) }
      let(:transaction_type5) { create(:transaction_type5, address: addresses_eth) }
      let(:external_service_transaction_type) {
        create(
          :external_service_transaction_type,
          name: '普通　米ドル　円に変換',
          external_service: external_service,
          transaction_type: transaction_type5
        )
      }

      before do
        external_service_transaction_type
        dollar_yen_20251001
      end

      context 'when 出金' do
        # date,transaction_type,deposit_quantity,deposit_rate,withdrawal_quantity,exchange_en
        it 'should replace from context to transaction_type.name.' do
          dollar_yen_transaction = instance.to_dollar_yen_transaction
          expect(dollar_yen_transaction).to eq([ '2025/10/01', transaction_type5.name, nil, nil, '85', nil ])
        end
      end

      context 'when 入金' do
        let(:transaction_type2) { create(:transaction_type2, address: addresses_eth) }
        let(:row) {
          [ '2025/10/01', '利息', nil, '0.03', '501.92', '-' ]
        }
        let(:external_service_transaction_type) {
          create(
            :external_service_transaction_type,
            name: '利息',
            external_service: external_service,
            transaction_type: transaction_type2
          )
        }

        # date,transaction_type,deposit_quantity,deposit_rate,withdrawal_quantity,exchange_en
        it 'should replace from context to transaction_type.name.' do
          dollar_yen_transaction = instance.to_dollar_yen_transaction
          expect(dollar_yen_transaction).to eq([ '2025/10/01', transaction_type2.name, '0.03', '148.17', nil, nil ])
        end
      end
    end
  end
end
