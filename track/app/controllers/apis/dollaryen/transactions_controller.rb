class Apis::Dollaryen::TransactionsController < ApplicationController
  # include ActionController::Cookies

  def index
    # session情報を取得
    # Current.session ||= find_session_by_cookie
    # sessionでは以下の値が取れる
    # まずはこれ

    # cookies.signed.permanent[:session_id] = 1
    # cookies.delete(:session_id)
    # #の挙動
    # puts cookies.signed[:session_id]



    # const obj = { chain_id: chainId, message: message, signature: signature, nonce: nonce_result.nonce, domain:  domain};

    # verify call

    # これに必要なのが
    #    chain_id: int
    #  message: str
    #  signature: str
    #  nonce: str
    #  domain: str

    # default
    limit = params[:limit]
    limit = 50 unless limit.present?
    offset = params[:offset]
    offset = 0 unless offset.present?

    # セッションで置き換える
    address = params[:address]
    address = Address.where(address: params[:address]).first
    address_id = 0
    address_id = address.id if address.present?

    base_sql = DollarYenTransaction.preload(:transaction_type).where("address_id = ?", address_id)
    total = base_sql.all.count
    dollaryen_transactions = base_sql.limit(limit).offset(offset).order(date: :desc,  transaction_type_id: :asc)

    # 　結果はhashでいい
    # nilの場合もあるので関数かな。
    # {a:1, b:2}
    responses = dollaryen_transactions.map do |dollaryen_transaction|
      {
        date: dollaryen_transaction.date.strftime("%Y/%m/%d"),
        transaction_type_name: dollaryen_transaction.transaction_type.name,
        deposit_rate: dollaryen_transaction.deposit_rate_on_screen,
        deposit_quantity: dollaryen_transaction.deposit_quantity_on_screen,
        deposit_en: dollaryen_transaction.deposit_en_screen,
        withdrawal_rate: dollaryen_transaction.withdrawal_rate_on_screen,
        withdrawal_quantity: dollaryen_transaction.withdrawal_quantity_on_screen,
        withdrawal_en: dollaryen_transaction.withdrawal_en_on_screen,
        balance_rate: dollaryen_transaction.balance_rate_on_screen,
        balance_quantity: dollaryen_transaction.balance_quantity_on_screen,
        balance_en: dollaryen_transaction.balance_en_on_screen
      }
    end
    render json: { total: total, dollaryen_transactions: responses }, status: :ok
  end

  def show
    dollaryen_transaction = DollarYenTransaction.find_by(id: params[:id])
    unless dollaryen_transaction.present?
      render json: { errors: [ { msg: "データが存在しません。" } ] }, status: :not_found
      return
    end
    render json: dollaryen_transaction, status: :ok
  end

  # TODO params[:address]はsessionに置き換える
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
      withdrawal_rate = dyt.calculate_withdrawal_rate if dyt.withdrawal?
      withdrawal_en = dyt.calculate_withdrawal_en if dyt.withdrawal?
      exchange_difference = dyt.calculate_exchange_difference(withdrawal_en: withdrawal_en) if dyt.withdrawal?
      balance_quantity = dyt.calculate_balance_quantity
      balance_en = dyt.calculate_balance_en
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
  # 　一旦これで作成
  # TODO
  # uploadはsolid queで実行かな
  def csv_import
    file = params[:file]

    unless file.present?
      render json: { errors: [ { msg: "ファイルが存在しません" } ] }, status: :bad_request
      return
    end

    address = params[:address]
    address = Address.where(address: params[:address]).first

    service = FileUploads::DollarYenTransactionDepositCsv.new(address: address, file: file)
    errors = service.validation_errors
    if errors.present?
      render json: { errors: errors }, status: :bad_request
      return
    end

    # CsvImport


    service.execute

    # # 　100件を超えるデータはバックエンド
    # if errors.size > 100
    #   # 　キューに登録して終わり
    # else
    #   # 　リアルタイムでinsert
    #   service.bulk_insert
    # end

    render status: :created
  end

  def find_session_by_cookie
    Session.find_by(id: cookies.signed[:session_id])
  end
end
