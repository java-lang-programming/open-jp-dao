class DollarYenTransactions::CsvCoordinationsController < ApplicationViewController
  include Nav

  before_action :verify

  # 　まずは権限なしで
  def index
    header_session
    address = @session.address

    # TODO ここでプランがあるか判断

    # 外部連携しているtransaction_type
    @external_service_transaction_types = address.external_service_transaction_types
  end

  def show
    header_session
    address = @session.address
    @external_service = ExternalService.find(params[:id])
    # TODO なければ404
    # 　不正なアクセスページ

    # 連携しているデータ一覧を取得
    @external_service_transaction_types = address.external_service_transaction_types.where(
      external_service_id: @external_service.id
    ).order(created_at: :asc)
  end

  def new
    header_session
    address = @session.address

    @external_service = ExternalService.find(params[:id])

    # Address から TransactionType を経由して ExternalServiceTransactionType を build
    # 1. 中間テーブルを build
    transaction_type = address.transaction_types.build
    # 2. その先に目的のオブジェクトを build
    @form = transaction_type.build_external_service_transaction_type
    view = Views::CsvCoordinationForm.new
    @form_status = view.form_status

    # 登録済みのtransaction_typeを取得
    transaction_type_ids = address.external_service_transaction_types.where(
      external_service_id: @external_service.id
    ).map(&:transaction_type_id)

    @transaction_types = address.transaction_types.where.not(id: transaction_type_ids)
  end

  def create
    request = params.require(:external_service_transaction_type).permit(:transaction_type_id, :name)
  end
  #
  # def destroy
  #
  # end

  private

  def header_session
    @user = user
    @notification = notification
  end
end
