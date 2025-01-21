class Apis::Dollaryen::ForeigneExchangeGainController < ApplicationController
  before_action :verify_v2, only: [ :index ]

  # ここのユーザー取得から
  def index
    session = find_session_by_cookie
    address = Address.where(address: session.address.address).first

    # ない場合は現在のデフォルト。あとは1900 - 2100までにしておく
    year = params[:year]
    year = Date.today.year unless year.present?

    # http://localhost:3000/apis/dollaryen/foreigne_exchange_gain?address=0x00001E868c62FA205d38BeBaB7B903322A4CC89D?year=2024
    transaction_type_ids = TransactionType.where(kind: TransactionType.kinds[:withdrawal]).where(address_id: address.id).map do |t|
      t.id
    end

    unless transaction_type_ids.present?
      render json: { errors: [ { msg: "withdrawalの取引種別が存在しません" } ] }, status: :bad_request
      return
    end

    # ここでwithdrawalを取得
    start_date = Time.new(year, 1, 1)
    end_date = Time.new(year, 12, 31)

    dollaryen_transactions = DollarYenTransaction.preload(:transaction_type).where(address_id: address.id).where(transaction_type_id: transaction_type_ids).where(date: (start_date..end_date))
    total = dollaryen_transactions.count

    # 為替差額
    foreign_exchange_gain = dollaryen_transactions.inject (0) { |sum, t| sum += t.exchange_difference }

    responses = dollaryen_transactions.map do |dollaryen_transaction|
      {
        date: dollaryen_transaction.date.strftime("%Y/%m/%d"),
        transaction_type_name: dollaryen_transaction.transaction_type.name,
        withdrawal_rate: dollaryen_transaction.withdrawal_rate_on_screen,
        withdrawal_quantity: dollaryen_transaction.withdrawal_quantity_on_screen,
        withdrawal_en: dollaryen_transaction.withdrawal_en_on_screen
      }
    end

    render json: { date: { start_date: start_date.strftime("%Y-%m-%d"), end_date: end_date.strftime("%Y-%m-%d") }, data: { total: total, dollaryen_transactions: responses }, foreign_exchange_gain: foreign_exchange_gain }, status: :ok
  end
end
