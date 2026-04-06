class ProductsController < ApplicationViewController
  include Nav
  before_action :verify, only: [ :index, :show ]

  def index
  	
  end

  def show
  	# TODO 以下の値はpythonから取得
  	# /api/ethereum/:chain_id/contracts/:name?func=payOneMonth
  	# api/ethrimu/:chain_id/contracsts
  	# クエリで関数だけを絞れるようにする
  	# name, address, abiを返す
  	# 自身の作成か、外部のかも管理しておく
  	jpyc_sepo = '0xE7C3D8C9a439feDe00D2600032D5dB0Be71C3c29'
  	payment_abi = 'function approve(address,uint256) returns (bool)'
  	payment_address = '0x88ee579c43e387db178142Fcfc220fFC2b016145'
  	payment_abi_payOneMonth = 'function payOneMonth()'
  	@payment_config = {
      jpyc_address: jpyc_sepo,
      jpyc_abi_approve: payment_abi,
      payment_address: payment_address,
      payment_abi: payment_abi_payOneMonth,
    }
  end
end
