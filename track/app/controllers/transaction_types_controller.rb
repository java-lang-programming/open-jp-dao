class TransactionTypesController < ApplicationViewController
  before_action :verify, only: [ :index, :edit, :new, :destroy ]

  skip_before_action :verify_authenticity_token, only: [ :destroy ]

  def index
    header_session
    base_sql = @session.address.transaction_types
    @total = base_sql.all.count
    @transaction_types = base_sql.order(id: :asc)
  end

  def new
    header_session
    @kinds = TransactionType.kinds_collection
    @transaction_type = TransactionType.new
  end

  def create
    header_session
    request = params.require(:transaction_type).permit(:name, :kind)
    transaction_type = TransactionType.new(name: request[:name], kind: request[:kind].to_i, address: @session.address)
    transaction_type.save

    redirect_to transaction_types_path, notice: "作成しました"
  end

  def edit
    header_session
    @kinds = TransactionType.kinds_collection
    @dollar_yen_transactions_count = @session.address.dollar_yen_transactions.where(transaction_type_id: params[:id]).count
    @transaction_type = @session.address.transaction_types.where(id: params[:id]).first
  end

  def update
    header_session
    request = params.require(:transaction_type).permit(:name, :kind)
    transaction_type = @session.address.transaction_types.where(id: params[:id]).first
    transaction_type.name = request[:name]
    transaction_type.kind = request[:kind].to_i
    transaction_type.save

    redirect_to transaction_types_path, notice: "更新しました"
  end

  def destroy
    header_session

    transaction_type = @session.address.transaction_types.where(id: params[:id]).first
    dollar_yen_transactions_count = @session.address.dollar_yen_transactions.where(transaction_type_id: params[:id]).count
    if dollar_yen_transactions_count > 0
      return redirect_to transaction_types_path, notice: transaction_type.name + "の取引データが存在します。取引データを削除してから取引種別を削除してください"
    end

    transaction_type.destroy

    redirect_to transaction_types_path, notice: "#{transaction_type.name}を削除しました"
  end

  private

    def header_session
      @user = user
      @notification = notification
    end
end
