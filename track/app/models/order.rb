class Order < ApplicationRecord
  belongs_to :product
  belongs_to :address
  belongs_to :payment

  has_one :blockchains_order

  enum :status, {
    pending: 0,    # 決済待ち（注文ボタンを押した直後）
    completed: 1,  # 決済完了（サービス提供・ダウンロード可能状態）
    failed: 2,     # 決済失敗（カードエラーなど）
    cancelled: 3,  # キャンセル（ユーザー操作や有効期限切れ）
    refunded: 4    # 返金済み（運営による事後の返金処理）
  }, default: :pending

  def generate_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def copy_product_price
    # 注文作成時の商品の価格を保存（値上げ対策）
    self.price = product.price if product.present?
  end

  # 決済が成功した時に呼ぶメソッド
  def mark_as_completed!
    update!(status: :completed)
    # ここでサンクスメールを送ったり、商品の閲覧権限を付与したりする
  end

  # 決済が失敗した時に呼ぶメソッド
  def mark_as_failed!
    update!(status: :failed)
  end
end
