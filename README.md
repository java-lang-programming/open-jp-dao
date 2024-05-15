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
