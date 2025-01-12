require 'rails_helper'

RSpec.describe Session, type: :model do
  let(:addresses_eth) { create(:addresses_eth) }
  let(:session_sepolia) { create(:session_sepolia, address: addresses_eth) }
  let(:session_ethereum_mainnet) { create(:session_ethereum_mainnet, address: addresses_eth) }

  describe 'network' do
    context 'sepoliaの場合' do
      it 'should be sepolia.' do
        expect(session_sepolia.network).to eq("Ethereum Sepolia")
      end
    end

    context 'mainの場合' do
      it 'should be main.' do
        expect(session_ethereum_mainnet.network).to eq("Ethereum Mainnet")
      end
    end
  end

  describe 'last_login' do
    context 'yyyy/mm/ddの場合' do
      it 'should be 19size.' do
        expect(session_ethereum_mainnet.last_login.size).to eq(19)
      end
    end
  end
end
