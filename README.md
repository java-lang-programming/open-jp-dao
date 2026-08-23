# Open JP Dao

日本の合同会社形式のDaoを構築するためのオープンソースコードです。日本以外のDaoでも利用できます。

実験と検証中のコードですが、gitHubにあげていきます。

需要があればフレームワーク/クラウドサービス化も目指していきたいと思います。

# 合同会社型DAO

[DAOルールメイクに関する提言](https://storage2.jimin.jp/pdf/news/policy/207470_2.pdf)

# 仕様

## 社員権

- 業務執行社員 - contracts/src/contracts/EmployeeAuthorityWorkerNFT.sol
- その他社員 - contracts/src/contracts/EmployeeAuthorityHolderNFT.sol

## 投票権

- リワードトークン - contracts/src/contracts/ERC20VotesToken.sol

## ガバナンス 

- ガバナンス -  contracts/src/contracts/OpenJpDaoGovernor.sol

## プロジェクト構成

当プロジェクトは monorepo（モノリポ）形式で構成されています。

/
├── track/        # Rails 8 API / バックエンドアプリケーション
│   └── README.md # セットアップ・起動手順・各種コマンド
└── backend/      # fast api / ブロックチェーンAPIアプリケーション
│   └── README.md # セットアップ・起動手順・各種コマンド

### 主要ディレクトリの役割

- **`./track`**: Ruby on Rails で作成されたバックエンドプロジェクト。開発環境の起動方法や環境変数の設定等は `./track/README.md` を参照してください。
- - **`./backend`**: fast api で作成されたブロックチェーンAPIアプリケーション。開発環境の起動方法や環境変数の設定等は `./backend/README.md` を参照してください。
