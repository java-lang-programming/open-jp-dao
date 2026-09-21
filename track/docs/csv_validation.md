1. 概要

アップロードされたCSVファイル（銀行・クレジットカード明細等）のヘッダーおよび構造を解析し、適切なフォーマットか、あるいは別機能のフォーマットかを判定するAPIを構築する。

2. アーキテクチャ構成

app/
  controllers/
    apis/
      csv_validations_controller.rb
services/
  financial_csv/
    base_adapter.rb
    detector.rb
    adapters/
      mufg_bank.rb
      mufg_card.rb
      rakuten_card.rb
      # 今後追加されるアダプター

3. インターフェース仕様
   エンドポイント
   POST /api/csv_validations

   リクエスト
   Content-Type: multipart/form-data
    
   Body:
    file: File（必須）
    target_type: String（必須、例: "mufg_bank", "rakuten_card", "dollar_yen_transaction"）

レスポンス仕様 (200 OK)
パターン1: 判定成功（期待した機能のCSVと一致）
JSON
{
"csv_type": "mufg_bank",
"errors": [] 
}

パターン2: 判定失敗（別の機能・画面のCSVと一致した場合）
JSON
{
"csv_type": "rakuten_card",
"errors": [
 {
   "message": "このファイルは「楽天カード利用明細画面」用のCSVです。対象の画面からアップロードしてください。"
 }
]
}

パターン3: 判定失敗（どのフォーマットにも該当しない場合）
JSON
{
"csv_type": null,
"errors": [
{
"message": "対応していないフォーマットです。ファイルをご確認ください。"
}
]
}

4.1. BaseAdapter (app/services/financial_csv/base_adapter.rb)
すべてのアダプタークラスの基底クラス。

責務:

各金融機関のヘッダー定義・画面名の保持

表記揺れ（新旧ヘッダー名）のエイリアス定義

match?(sample_lines) メソッドの提供

4.2. 個別アダプターの実装例 (app/services/financial_csv/adapters/)
新旧ヘッダー変更に対応するため、column_mappings 内で複数のエイリアスを定義する。

4.3. Detector (app/services/financial_csv/detector.rb)
アップロードされたCSVの先頭行を読み込み、アダプターと照合する。

処理フロー:

ファイルの先頭10行を取得（文字コードShift_JIS/UTF-8の読み込み考慮）

target_type に該当するアダプターで match? を実行

一致しない場合、ADAPTERS 一覧から match? が true になるアダプターを検索

見つかればその画面名を付与して mismatch エラーを返却。見つからなければ not_found を返却

4.4. Controller (app/controllers/api/v1/csv_validations_controller.rb)

5. 単体テスト要件 (RSpec)

LLMに実装させる際は、以下のテストケースもセットで生成させること。

正常系:

表記揺れ（旧ヘッダー名）のCSVを渡しても正常に判定されること。

異常系 (mismatch):

target_type: "mufg_bank" でリクエストしたが、ファイルが rakuten_card の形式だった場合

異常系 (not_found):

全く関係のないフォーマットのCSVをアップロードした場合