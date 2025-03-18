class TransactionTypesController < ApplicationViewController
  before_action :verify, only: [ :index, :destroy ]

  skip_before_action :verify_authenticity_token, only: [ :destroy ]

  def index
    @user = user
    base_sql = @session.address.transaction_types
    @total = base_sql.all.count
    @transaction_types = base_sql.order(id: :asc)
  end

  def destroy
    @user = user

    dollar_yen_transactions_count = @session.address.dollar_yen_transactions.where(transaction_type_id: params[:id]).count
    if dollar_yen_transactions_count > 0
      return redirect_to transaction_types_path, notice: "#{transaction_type.name}の取引データが存在します。取引データを削除してから取引種別を削除してください"
    end

    transaction_type = @session.address.transaction_types.where(id: params[:id]).first
    transaction_type.destroy

    redirect_to transaction_types_path, notice: "#{transaction_type.name}を削除しました"
  end
end
