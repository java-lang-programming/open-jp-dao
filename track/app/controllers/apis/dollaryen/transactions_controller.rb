require "csv"

class Apis::Dollaryen::TransactionsController < ApplicationController
  def index
    # default
    dollaryen_transactions = DollarYenTransaction.where(limit: 50, ofset: 0)
    total = DollarYenTransaction.all.count
    # dollaryen_transactions.map do |dollaryen_transaction|

    # end
    json = { total: total, dollaryen_transaction: dollaryen_transactions }
    render json: json, status: :ok
  end

  def show
    dollaryen_transaction = DollarYenTransaction.find_by(id: params[:id])
    unless dollaryen_transaction.present?
      render json: { errors: [ { msg: "データが存在しません。" } ] }, status: :not_found
      return
    end
    render json: dollaryen_transaction, status: :ok
  end

  def create
    date = params[:date]
    if date.length != 10
      render json: { errors: [ { msg: "dateの文字数が不正です。dataはyyyy-mm-ddの形式である必要があります。" } ] }, status: :bad_request
      return
    elsif date.split("-").size != 3
      render json: { errors: [ { msg: "dateのフォーマットが不正です。dataはyyyy-mm-ddのハイフン形式である必要があります。" } ] }, status: :bad_request
      return
    else
      temp = date.split("-")
      target_date = Time.new(temp[0], temp[1], temp[2])

      transaction_type = TransactionType.where(id: params[:transaction_type_id]).first
      unless transaction_type.present?
        render json: { errors: [ { msg: "transaction_typeが存在しません。" } ] }, status: :bad_request
        return
      end

      address = Address.where(address: params[:address]).first
      unless address.present?
        render json: { errors: [ { msg: "addressが存在しません。" } ] }, status: :bad_request
        return
      end

      dyt = DollarYenTransaction.new(transaction_type: transaction_type, date: target_date, deposit_rate: params[:deposit_rate], deposit_quantity: params[:deposit_quantity], withdrawal_quantity: params[:withdrawal_quantity], exchange_en: params[:exchange_en], address: address)
      unless dyt.valid?
        emsgs = dyt.errors.map do |e|
          { msg: e.full_message }
        end
        render json: { errors: emsgs }, status: :bad_request
        return
      end

      en = dyt.calculate_deposit_en if dyt.deposit?
      withdrawal_rate = dyt.calculate_withdrawal_rate(target_date: target_date) if dyt.withdrawal?
      withdrawal_en = dyt.calculate_withdrawal_en(target_date: target_date) if dyt.withdrawal?
      exchange_difference = dyt.calculate_exchange_difference(withdrawal_en: withdrawal_en) if dyt.withdrawal?
      balance_quantity = dyt.calculate_balance_quantity(target_date: target_date)
      balance_en = dyt.calculate_balance_en(target_date: target_date)
      balance_rate = dyt.calculate_balance_rate(balance_quantity: balance_quantity, balance_en: balance_en)

      dyt.deposit_en = en if dyt.deposit?
      dyt.withdrawal_en = withdrawal_en if dyt.withdrawal?
      dyt.withdrawal_rate = withdrawal_rate if dyt.withdrawal?
      dyt.exchange_difference = exchange_difference if dyt.withdrawal?
      dyt.balance_quantity = balance_quantity
      dyt.balance_en = balance_en
      dyt.balance_rate = balance_rate

      dyt.save
    end
    render status: :created
  end

  # TODO csvはmodelでやる。
  # models csvsを要して使う
  # insertしてみる
  # まずは設計から
  def csv_upload
    file = params[:file]
    if file.present?
      puts "fileだよ"
      File.open(file, "r") do |file|
        # puts file.empty?
        # CSV.new(file, headers: true).each do |row|
        #   puts "-----"
        #   puts row
        # end
        # ファイルから一行ずつ
        index = 0
        CSV.foreach(file) do |row|
          index = index + 1
          next if index == 1
          line = Files::DollarYenTransactionDepositCsv.new(row: row)
          p line.inspect
        end
      end
    end

    render status: :created
  end
end
