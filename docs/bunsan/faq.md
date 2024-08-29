まずやること

投票の作成
の削除
更新
表示

投票一覧

投票する
委任する

投票結果を見る。

====
railsのviwe


画面 

Dao > 投票 

投票一覧　→ 選択して表示 投票 → 
投票作成 → 入力して作成

======
設計

api/votes post

投票の作成(countの場合)

solidity


        const transferCalldata = VoteToken.interface.encodeFunctionData("transfer", [teamAddress, grantAmount]);

        // const proposalId = 
        // ここでproposalIdは取得できない。イベントから取得する
        // https://forum.openzeppelin.com/t/question-regarding-the-governor-propose/21678/3
        const proposal_tx = await Governor.propose(
          [VoteToken.address],
          [0],
          [transferCalldata],
          "Proposal #1: Give grant to team",
        );



パラメーター

api/vote/create

1. voteTokenAddress
2. call data              何もしない場合ってできる？ nameの実行とかかな。  投票でどうするか。
3. 投票内容

1. 権限チェック
2. パラメーターチェック
3. prppose

でいけるはず。


やること

no call data

https://ethereum.stackexchange.com/questions/98177/how-to-pass-a-blank-bytes-calldata-into-a-solidity-function-call




