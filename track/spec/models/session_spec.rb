require 'rails_helper'

RSpec.describe Session, type: :model do
  let(:addresses_eth) { create(:addresses_eth) }
  let(:addresses_solana) { create(:addresses_solana) }
  let(:session_sepolia) { create(:session_sepolia, address: addresses_eth) }
  let(:session_ethereum_mainnet) { create(:session_ethereum_mainnet, address: addresses_eth) }
  let(:session_solana) { create(:session_solana, address: addresses_solana) }

  describe "validations" do
    context 'ethereum' do
      it "requires domain when chain_id is MAINNET" do
        session = Session.new(
          chain_id: Session::ETHEREUM_MAINNET,
          message: "msg",
          signature: "sig",
          domain: nil,
          address: addresses_eth
        )
        expect(session).not_to be_valid
        expect(session.errors[:domain]).to include("を入力してください")
      end

      it "is valid when chain_id and domain exist." do
        session = Session.new(
          chain_id: Session::ETHEREUM_MAINNET,
          message: "Sign in with ethereum to the WanWan.",
          signature: "0x1234",
          domain: 'localhost',
          address: addresses_eth
        )
        expect(session).to be_valid
      end
    end

    # solanaの場合はchain_idとdomainが存在しない
    it "is valid when chain_id and domain are nil." do
      session = Session.new(
        chain_id: Session::SOLANA,
        message: "Sign in with phantom to the WanWan.",
        signature: "0x123",
        domain: nil,
        address: addresses_solana
      )
      expect(session).to be_valid
    end
  end

  describe 'network' do
    context 'ethereum sepoliaの場合' do
      it 'should be ethereum sepolia.' do
        expect(session_sepolia.network).to eq("Sepolia")
      end
    end

    context 'ethereum mainの場合' do
      it 'should be ethereum main.' do
        expect(session_ethereum_mainnet.network).to eq("Ethereum Mainnet")
      end
    end

    context 'solanaの場合' do
      it 'should be Solana.' do
        expect(session_solana.network).to eq("Solana")
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
