# 依頼内容
以下の要件に基づいて、RailsのコントローラーとRSpecを実装してください。

# 前提条件
- Rails 8.1
- Ruby 4.0.1
- RSpec + FactoryBot使用

# 要件
- モデル名: Order (status: string, product_id: integer)
- コントローラー名: Apis::OrdersController
- アクション: create
- 処理内容:
    - `product_id` を受け取って `Order` データを作成する
    - `product_id` は必須入力
    - 作成時、`order` の `status` は "pending" とする
    - 成功時は JSON で `id` を返却する
    - ストロングパラメータ（order_params）を使用すること
    - バリデーションエラー時は 422 Unprocessable Entity を返すこと

# RSpec要件
- `rails_helper` を require すること
- 正常系（作成成功）と異常系（バリデーションエラー）のテストを含めること

# 出力ファイルパス
1. コントローラー: app/controllers/apis/orders_controller.rb
2. RSpec: spec/requests/apis/orders_spec.rb