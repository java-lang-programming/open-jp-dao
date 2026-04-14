class Product < ApplicationRecord
  has_many :orders
  enum :status, {
    draft: 0,      # 下書き（管理者のみ）
    scheduled: 1,  # 公開予約（日時判定とセット）
    active: 2,     # 公開中
    limited: 3,    # 限定公開（一覧非表示）
    sold_out: 4,   # 売り切れ（購入不可だが表示は残す）
    archived: 5    # 廃止（過去の注文履歴参照用）
  }

  # 公開中かつ公開日時を過ぎているものを取得するスコープ
  # published_at が nil のものは除外して、過去の日付のものだけを取得する
  scope :published, -> {
    where(status: [ :active, :scheduled ])
    .where.not(published_at: nil) # nilを除外
    .where("published_at <= ?", Time.current)
  }

  # def set_published_at_if_active
  #   # ステータスが active に変更されたとき、もし published_at が空なら現在時刻を入れる
  #   if active? && status_changed? && published_at.nil?
  #     self.published_at = Time.current
  #   end
  # end
end
