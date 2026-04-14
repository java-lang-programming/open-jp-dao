class ProductsController < ApplicationViewController
  include Nav
  before_action :verify, only: [ :index, :show ]

  def index
  end

  # Deploying contracts with the account: 0x91582E868c62FA205d38BeBaB7B903322A4CC89D
  # Deployer balance set!
  # Account balance: 100000000000000000000
  # --------------------------------------------
  # JpycPayment deployed to: 0xc9d52B4440BF0184d9667bD12927eF36239846cd
  # JPYC Address set to: 0xE7C3D8C9a439feDe00D2600032D5dB0Be71C3c29
  # Treasury Address set to: 0x64300314Bb1860D3b1E476009D9eEd6a01C8b2DE
  def show
    # TODO 以下の値はpythonから取得
    # /api/ethereum/:chain_id/contracts/:name?func=payOneMonth
    # api/ethrimu/:chain_id/contracsts
    # クエリで関数だけを絞れるようにする
    # name, address, abiを返す
    # 自身の作成か、外部のかも管理しておく
    jpyc_sepo = "0xE7C3D8C9a439feDe00D2600032D5dB0Be71C3c29"
    payment_abi = "function approve(address,uint256) returns (bool)"
    payment_address = "0xc9d52B4440BF0184d9667bD12927eF36239846cd"
    payment_abi_payOneMonth = "function payOneMonth()"
    @payment_config = {
      jpyc_address: jpyc_sepo,
      jpyc_abi_approve: payment_abi,
      payment_address: payment_address,
      payment_abi: payment_abi_payOneMonth
    }
  end
end
