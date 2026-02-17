class Csv < ApplicationRecord
  # UFJ
  ID_UFJ = 1
  # 楽天カード
  ID_RAKUTEN_CARD = 2
  # 中間テーブルとのリレーション
  has_many :csv_ledger_items, dependent: :destroy
  # LedgerItemとの多対多のリレーション
  has_many :ledger_items, through: :csv_ledger_items

  # 　ここでkindを取れるようにする
  def self.find_kind_by_id(id:)
    if id == ID_UFJ
      FileUploads::GenerateMaster::UFJ_YAML
    elsif id == ID_RAKUTEN_CARD
      FileUploads::GenerateMaster::RAKUTEN_CARD_YAML
    end
  end
end
